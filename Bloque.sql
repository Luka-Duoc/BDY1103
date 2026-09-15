set serveroutput on;

DECLARE
    cursor c_orden_entrega is 
        select
            id_orden,
            fecha_recepcion,
            fecha_estimada,
            fecha_entrega,
            id_estado_orden
        from orden where id_estado_orden = 8;
    
    -- Fechas
    v_fecha_corte           date;
    v_dias_atraso           number;
    v_dias_estadia_total    number;
    v_estado                varchar2(50);
    
    -- Cantidad Ordenes
    
    type r_resumen_sucursal is record (
        id_sucursal     sucursal.id_sucursal%type,
        nombre_sucursal sucursal.nombre_sucursal%type,
        total_ordenes   number
    );
    
    type t_arreglo_sucursales is varray(10) of r_resumen_sucursal;
    
    v_resumen t_arreglo_sucursales := t_arreglo_sucursales();
    
    cursor c_conteo_sucursal is
        select
            s.id_sucursal,
            s.nombre_sucursal,
            count(o.id_orden) as cantidad
        from sucursal s
        left join orden o on s.id_sucursal = o.id_sucursal
        group by s.id_sucursal, s.nombre_sucursal
        order by s.id_sucursal;
    
    
    -- Bono Tecnicos
    cursor c_total_reparaciones is
        select
            t.id_tecnico,
            t.nombre,
            count(r.id_reparacion) as total,
            t.sueldo
        from tecnico t
        left join reparacion r on t.id_tecnico = r.id_tecnico
        group by t.id_tecnico, t.nombre, t.sueldo;
        
    cursor c_bonos is
        select
            rango_minimo as min,
            rango_maximo as max,
            porc_bono as porc
        from bono_equipos_reparados;
    
    v_bono  number;
    
    
    -- TECNICO INACTIVO
    
    e_tec_inactivo EXCEPTION;
    
    cursor c_inactivos is 
        select
            t.id_tecnico,
            t.nombre || ' ' || t.apellido as nombre,
            r.id_reparacion,
            o.id_orden,
            o.fecha_entrega
        from tecnico t
        join reparacion r on t.id_tecnico = r.id_tecnico
        join orden o on r.id_orden = o.id_orden
        where t.estado = 'Inactivo' and o.fecha_entrega is null;       
        
        v_total_inactivos   number    := 0;
    
BEGIN
    execute immediate 'truncate table resumen_tecnico';
    execute immediate 'truncate table resumen_sucursal';
    execute immediate 'truncate table log_error';
    execute immediate 'truncate table entrega_orden';

    -- Fecha
    for o in c_orden_entrega loop
        
        if o.fecha_entrega is not null then
            v_fecha_corte := o.fecha_entrega;
        
        else 
            v_fecha_corte := trunc(sysdate);
        end if;
        
        v_dias_atraso := v_fecha_corte - o.fecha_estimada;
        
        v_dias_estadia_total := v_fecha_corte - o.fecha_recepcion;
        
        if v_dias_atraso <= 0 then
            v_estado := 'Entregado a tiempo';
        elsif v_dias_atraso between 1 and 3 then
            v_estado := 'Atrasado';
        elsif v_dias_atraso between 4 and 7 then
            v_estado := 'Atraso considerable';
        else
            v_estado := 'Sin avances';        
        end if;
        
        insert into entrega_orden(
        id_orden, 
        fecha_recepcion,
        fecha_estimada, 
        fecha_entrega,
        descripcion_entrega,
        id_estado_orden) values(o.id_orden,
        o.fecha_recepcion, 
        o.fecha_estimada, 
        o.fecha_entrega,
        v_estado,
        o.id_estado_orden);
    
    end loop;
    
    -- Total ordenes
    for tot in c_conteo_sucursal loop
        v_resumen.extend;
        
        v_resumen(v_resumen.count).id_sucursal      := tot.id_sucursal;
        v_resumen(v_resumen.count).nombre_sucursal  :=tot.nombre_sucursal;
        v_resumen(v_resumen.count).total_ordenes    :=tot.cantidad;

        insert into resumen_sucursal (id_sucursal, nombre_sucursal, total_reparaciones) values(tot.id_sucursal, tot.nombre_sucursal, tot.cantidad);
    end loop;
        
    -- Calculo bono
    for t in c_total_reparaciones loop
        v_bono := 0;
        for b in c_bonos loop
            if t.total between b.min and b.max then
                v_bono := trunc(t.sueldo * (b.porc / 100));
            end if;
        end loop;        
        
        insert into resumen_tecnico (
                                            fecha_proceso,
                                            id_tecnico,
                                            nombre_tecnico,
                                            reparaciones,
                                            sueldo_base,
                                            monto_bono,
                                            sueldo_total
                                        ) values (
                                            sysdate,
                                            t.id_tecnico,
                                            t.nombre,
                                            t.total,
                                            t.sueldo,
                                            v_bono,
                                            (t.sueldo + v_bono)
                                        );
    end loop;
    
    
    -- Busqueda inactivos
    
    for t in c_inactivos loop
        v_total_inactivos := v_total_inactivos + 1;
        
        begin
            RAISE e_tec_inactivo;
            
        exception
            when e_tec_inactivo then
                insert into log_error (fecha_error, descripcion) values(sysdate, 'Tecnico inactivo: ' ||  t.nombre 
                                                                        || ' en orden: ' || t.id_orden 
                                                                        || ' Reparacion: ' || t.id_reparacion);
                                                                        
                update reparacion set id_tecnico = null where id_reparacion = t.id_reparacion;
                                                                        
                dbms_output.put_line('Tecnico ' || t.nombre || ' desasignado de la reparacion ' || t.id_reparacion);
        end; 
    end loop; 
    
    if v_total_inactivos = 0 then
        dbms_output.put_line('No hay tecnicos inactivos');
    else 
        dbms_output.put_line('Tecnicos inactivos: ' || v_total_inactivos);
        commit;
    end if;

    
END;
/


/*BLOQUE MANEJO DE STOCK*/

DECLARE
    
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
            rp.nombre_repuesto, 
            rp.stock_disponible, 
            rp.stock_minimo;
            
    v_total_quiebre     number  := 0;
    v_total_criticos    number  := 0;
    
BEGIN
    
    execute immediate 'truncate table alerta_stock';
    
    for reg in c_analisis_stock loop
        
        if reg.cantidad_utilizada > reg.stock_disponible then
            v_total_quiebre := v_total_quiebre + 1;
            
            insert into alerta_stock (id_reparacion, id_repuesto, nombre_repuesto,
                cantidad_requerida, stock_disponible, stock_minimo,
                nivel_alerta, detalle) values (
                                                reg.id_reparacion,
                                                reg.id_repuesto,
                                                reg.nombre_repuesto,
                                                reg.cantidad_utilizada,
                                                reg.stock_disponible,
                                                reg.stock_minimo,
                                                'QUIEBRE DE STOCK',
                                                'Faltante: ' || (reg.cantidad_utilizada - reg.stock_disponible) || ' unidad(es) para orden: ' || reg.id_orden
                                            );
            
        elsif (reg.stock_disponible - reg.cantidad_utilizada) <= reg.stock_minimo then
            v_total_criticos := v_total_criticos + 1;
            
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
    dbms_output.put_line('Alerta por repuestos con poco stock: ' || v_total_criticos);
    
END;
/