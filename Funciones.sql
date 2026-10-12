SET SERVEROUTPUT ON;

/*
***************************************************************************
************    PREGUNTA  SI TENI ALGUNA DUDA BATTISTONI           ********
**************************************************************************
Igual voy a comentar en varias partes para que entiendas lo que intento hacer
*/


-- calcular el bono estimado recibiendo el sueldo y reparaciones estimadas
create or replace function fn_calcular_bono(p_sueldo number, p_reparaciones number) return number is
 v_bono number := 0;
 
begin
    
    -- Recorre la tabla para calcular el bono estimado
    for b in (select rango_minimo, rango_maximo, porc_bono from bono_equipos_reparados) loop
        if p_reparaciones between b.rango_minimo and b.rango_maximo then
            v_bono := trunc(p_sueldo * (b.porc_bono / 100));
        end if;
    end loop;
    
    return v_bono;
end fn_calcular_bono;
/

-- Calcula el avance en las ordenes
create or replace function fn_atraso(p_fecha_estimada date, p_fecha_entrega date) return varchar2 is
    v_fecha_corte date;
    v_dias_atraso number;
    v_estado varchar2(50);
    
begin
    
    -- Asigna un estado a las ordenes 
    if p_fecha_estimada is not null then
        v_fecha_corte := p_fecha_entrega;
    else
        v_fecha_corte := trunc(sysdate);
    end if;
    
    v_dias_atraso := v_fecha_corte - p_fecha_estimada;
    
    if v_dias_atraso <= 0 then
        v_estado := 'Entregado a tiempo';
        
    elsif v_dias_atraso between 1 and 3 then
        v_estado := 'Atrasado';
    
    elsif v_dias_atraso between 4 and 7 then
        v_estado := 'Atraso considerable';
    
    else 
        v_estado := 'Sin avances';
    end if;
    
    return v_estado;

end fn_atraso;
/

-- Desvincular a tecnico inactivo de ordenes que le fueron asignadas
create or replace procedure sp_desasignar_tecnico (p_id_tecnico number) is
    v_nombre_tecnico    varchar2(200);
    v_estado_tecnico    varchar2(100);
    v_afectados         number := 0;
    
    cursor c_reparaciones_pendientes is
        select
            r.id_reparacion,
            o.id_orden
        from reparacion r
        join orden o on r.id_orden = o.id_orden
        where r.id_tecnico = p_id_tecnico and o.fecha_entrega is null;
        
begin
    
    -- Guardar los datos del tecnico para uso futuro
    select 
        nombre || ' ' || apellido,
        estado
    into v_nombre_tecnico, v_estado_tecnico
    from tecnico
    where id_tecnico = p_id_tecnico;
    
    --  Busca las reparaciones que el tecnico inactivo tiene asignado
    for reg in c_reparaciones_pendientes loop
        v_afectados := v_afectados + 1; -- Si el tecnico tiene reparaciones se suma 1
        
        -- Insertar el error con la informacin del tecnico, orden y reparacion
        insert into log_error (fecha_error, descripcion) values (
            sysdate,
            'Tecnico desvinculado: ' || v_nombre_tecnico || ', Estado: ' || v_estado_tecnico||
            ' en orden ' || reg.id_orden || ' reparacion ' || reg.id_reparacion 
        );
        
        update reparacion set id_tecnico = null where id_reparacion = reg.id_reparacion;
    end loop;
    
    -- Si hay reparaciones afectadas muestra un mensaje con el nombre y la cantidad de reparaciones asignadas
    
    if v_afectados > 0 then
        commit;
        dbms_output.put_line('Se desvinculo al tecnico ' || v_nombre_tecnico || ' de ' || v_afectados || ' reparaciones pendientes');
    else
        dbms_output.put_line('El tecnico ' || v_nombre_tecnico || ' no tiene reparaciones pendientes');
    end if;
    
    
exception
    when no_data_found then
        dbms_output.put_line('Error: El tecnico con ID ' || p_id_tecnico || ' no existe');
    when others then
    -- Si ocurre un error no se desvincula al tecnico pero igual se guarda la informacion mostrando el id del tecnico
        rollback;
        insert into log_error (fecha_error, descripcion) values (
            sysdate,
            'Error en procedimiento desasginar tecnico ' || p_id_tecnico
        );
        commit;
        dbms_output.put_line('Ocurrió un error inesperado al procesar al técnico ' || p_id_tecnico);
    
end sp_desasignar_tecnico;
/

-- Procedimiento que permite hacer inventario de stock (eliminar, añadir o actualizar stock)
create or replace procedure sp_actualizar_stock(p_id_repuesto number, p_cantidad number) is

    v_stock_actual number;
    v_nuevo_stock number;
    v_nombre varchar2(100);
    
begin
    
    select
        nombre_repuesto,
        stock_disponible
    into v_nombre,
    v_stock_actual
    from repuesto
    where id_repuesto = p_id_repuesto;
    
    v_nuevo_stock := v_stock_actual + p_cantidad;
    
    -- Evita el ingreso de stock negativo
    if v_nuevo_stock < 0 then
        raise_application_error(-20001, 'Error, el stock no puede ser menor a 0');
    end if;
    
    -- Actualiza el stock de repuesto
    update repuesto set stock_disponible = v_nuevo_stock where id_repuesto = p_id_repuesto;
    
    -- Si funciona muestra mensaje que muestra el stock anterior y el nuevo 
    commit;
    dbms_output.put_line('Repuesto ' || v_nombre || ' actualizado Stock anterior: ' || v_stock_actual || ' | Nuevo stock: ' || v_nuevo_stock);
    
    
exception
    when no_data_found then
        dbms_output.put_line('Error, El id del repuesto que busca no existe');
    
end sp_actualizar_stock;
/

-- Procedimiento central Permite limpiar las tablas evitando datos temporales o datos inutiles
create or replace procedure sp_cierre_mensual is
    
    -- Fecha de entrega de ordenes (Permite calcular si los pedidos entregados fueron entregados a tiempo)
    cursor c_ordenes_entrega is
        select
            id_orden,
            fecha_recepcion,
            fecha_estimada,
            fecha_entrega,
            id_estado_orden
        from orden
        where id_estado_orden = 8;
        
        -- Record que resume las ordenes totales de las sucursales
        type r_resumen_sucursal is record (
            id_sucursal         sucursal.id_sucursal%type,
            nombre_sucursal     sucursal.nombre_sucursal%type,
            total_ordenes       number
        );
        
        
        type t_arreglo_sucursales is varray(10) of r_resumen_sucursal;
        v_resumen t_arreglo_sucursales := t_arreglo_sucursales();
        
        -- Cursor para recorrer el total de ordenes por sucursales
        cursor c_conteo_sucursal is
            select
                s.id_sucursal,
                s.nombre_sucursal,
                count(o.id_orden) as cantidad
            from sucursal s
            left join orden o on s.id_sucursal = o.id_sucursal
            group by s.id_sucursal, s.nombre_sucursal
            order by s.id_sucursal;
    
        -- Total reparaciones de tecnicos activos
        cursor c_tecnicos is 
        select 
            id_tecnico,
            nombre || ' ' || apellido as nombre,
            sueldo
        from tecnico
        where estado = 'Activo';

    cursor c_reparaciones_tecnico (p_id_tecnico number) is
        select r.id_reparacion
        from reparacion r
        where r.id_tecnico = p_id_tecnico;

    -- Tecnicos inactivos con ordenes abiertas
    cursor c_inactivos is 
        select distinct t.id_tecnico
        from tecnico t
        join reparacion r on t.id_tecnico = r.id_tecnico
        join orden o on r.id_orden = o.id_orden
        where t.estado = 'Inactivo' 
          and o.fecha_entrega is null;

    v_total_reparaciones number;
    v_bono               number;
    v_total_inactivos    number := 0;
        
begin
    
    -- Limpiar tablas
    execute immediate 'truncate table resumen_tecnico';
    execute immediate 'truncate table resumen_sucursal';
    execute immediate 'truncate table log_error';
    execute immediate 'truncate table entrega_orden';
    
    -- Procesar las ordenes de entrega usando la funcion para determinar el atraso
    for o in c_ordenes_entrega loop
        insert into entrega_orden(
            id_orden, fecha_recepcion, fecha_estimada, fecha_entrega, descripcion_entrega, id_estado_orden
        ) values (
            o.id_orden, o.fecha_recepcion, o.fecha_estimada, o.fecha_entrega,
            fn_atraso(o.fecha_estimada, o.fecha_entrega),
            o.id_estado_orden
        );
    end loop;
    
    -- Ordenes por sucursales
    for tot in c_conteo_sucursal loop
        v_resumen.extend;
        v_resumen(v_resumen.count).id_sucursal     := tot.id_sucursal;
        v_resumen(v_resumen.count).nombre_sucursal := tot.nombre_sucursal;
        v_resumen(v_resumen.count).total_ordenes   := tot.cantidad;

        insert into resumen_sucursal (id_sucursal, nombre_sucursal, total_reparaciones)
        values (tot.id_sucursal, tot.nombre_sucursal, tot.cantidad);
    end loop;
    
    -- Calcular el bono de los tecnicos usando la funcion de calcluar bono
    for tec in c_tecnicos loop
        v_total_reparaciones := 0;

        for rep in c_reparaciones_tecnico(tec.id_tecnico) loop
            v_total_reparaciones := v_total_reparaciones + 1;
        end loop;

        v_bono := fn_calcular_bono(tec.sueldo, v_total_reparaciones);

        insert into resumen_tecnico (
            fecha_proceso, id_tecnico, nombre_tecnico, reparaciones, sueldo_base, monto_bono, sueldo_total
        ) values (
            sysdate, tec.id_tecnico, tec.nombre, v_total_reparaciones, tec.sueldo, v_bono, (tec.sueldo + v_bono)
        );
    end loop;
    
    -- Desvincular a tecnicos inactivos de las reparaciones asignadas
    for inact in c_inactivos loop
        v_total_inactivos := v_total_inactivos + 1;
        sp_desasignar_tecnico(inact.id_tecnico);
    end loop;

    commit;
    dbms_output.put_line('Cierre mensual completado.');
    
exception
    when others then
        rollback;
        dbms_output.put_line('Error inesperado');

end sp_cierre_mensual;
/

exec sp_cierre_mensual;
        

create or replace procedure sp_evaluar_inventario is
    cursor c_analisis_stock is
        select
            r.id_reparacion,
            r.id_orden,
            rp.id_repuesto,
            rp.nombre_repuesto,
            sum(ru.cantidad_utilizada) as cantidad_utilizada,
            rp.stock_disponible,
            rp.stock_minimo
        from reparacion r
        join repuesto_utilizado ru on ru.id_reparacion = r.id_reparacion
        join repuesto rp on ru.id_repuesto = rp.id_repuesto
        group by 
            r.id_reparacion,
            r.id_orden,
            rp.id_repuesto,
            rp.stock_disponible,
            rp.stock_minimo,
            rp.nombre_repuesto;
            
    v_total_quiebre number  := 0;
    v_total_critico number  := 0;
    
begin
    
    execute immediate 'truncate table alerta_stock';
    
    for reg in c_analisis_stock loop
        
        if reg.cantidad_utilizada > reg.stock_disponible then 
            v_total_quiebre := v_total_quiebre + 1;
            
            insert into alerta_stock (id_reparacion, id_repuesto, nombre_repuesto, cantidad_requerida, stock_disponible, stock_minimo, nivel_alerta, detalle)
            values (reg.id_reparacion,
                    reg.id_repuesto,
                    reg.nombre_repuesto,
                    reg.cantidad_utilizada,
                    reg.stock_disponible,
                    reg.stock_minimo,
                    'QUIEBRE DE STOCK',
                    'Faltante: ' || (reg.cantidad_utilizada - reg.stock_disponible) || ' unidad(es) para orden: ' || reg.id_orden
                                    );
                                    
        elsif (reg.stock_disponible - reg.cantidad_utilizada) <= reg.stock_minimo then
            v_total_critico := v_total_critico + 1;
            
            insert into alerta_stock (
                id_reparacion, id_repuesto, nombre_repuesto,
                cantidad_requerida, stock_disponible, stock_minimo,
                nivel_alerta, detalle) values (
                                                reg.id_reparacion,
                                                reg.id_repuesto,
                                                reg.nombre_repuesto,
                                                reg.cantidad_utilizada,
                                                reg.stock_disponible,
                                                reg.stock_minimo,
                                                'STOCK CRITICO',
                                                'Remanente proyectado: ' || (reg.stock_disponible - reg.cantidad_utilizada) || ' (Mínimo: ' || reg.stock_minimo || ')'
                                            );
            
        end if;
        
    end loop;
    commit;
    
    dbms_output.put_line('Alerta por repuestos sin stock: ' || v_total_quiebre);
    dbms_output.put_line('Alerta por repuestos con poco stock: ' || v_total_critico);

exception
    when others then
        rollback;
        dbms_output.put_line('Error inesperado, no se pudo evaluar el inventario');

end sp_evaluar_inventario;
/

exec sp_evaluar_inventario;


create or replace trigger tgr_validacion_tecnico
before insert or update of id_tecnico on reparacion
for each row
declare
    v_estado_tecnico    tecnico.estado%type;
    v_nombre            varchar2(100);
begin

   if :new.id_tecnico is not null then
        select
            nombre || ' ' || apellido,
            estado
        into v_nombre, v_estado_tecnico
        from tecnico
        where id_tecnico = :new.id_tecnico;
        
        if v_estado_tecnico != 'Activo' then
            raise_application_error(-20002, 'No se puede asignar al tecnico ' || v_nombre || ' Si esta inactivo' );
        end if;
    end if;
    
exception
    when no_data_found then
        raise_application_error(-20003, 'ERROR, No se encontro al tecnico');

end tgr_validacion_tecnico;
/

