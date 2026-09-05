set serveroutput on;

DECLARE
    cursor c_orden is 
        select
            id_orden,
            fecha_recepcion,
            fecha_estimada,
            fecha_entrega,
            id_estado_orden
        from orden;
    
    -- Fechas
    v_fecha_corte           date;
    v_dias_atraso           number;
    v_dias_estadia_total    number;
    v_estado                varchar2(50);
    
    -- Reparación
    cursor c_reparacion is
        select
            r.id_reparacion,
            r.id_orden,
            r.diagnostico
        from reparacion r
        join orden o on r.id_orden = o.id_orden;
        
    cursor c_repuestos_reparacion (p_id_reparacion number) is
        select
            ru.id_repuesto,
            sum(ru.cantidad_utilizada) as cantidad_utilizada,
            rp.nombre_repuesto,
            rp.stock_disponible,
            rp.stock_minimo
        from repuesto_utilizado ru
        join repuesto rp on ru.id_repuesto = rp.id_repuesto
        where ru.id_reparacion = p_id_reparacion
        group by ru.id_repuesto, rp.nombre_repuesto, rp.stock_disponible, rp.stock_minimo;
        
    e_stock_insuficiente EXCEPTION;
    
    v_error boolean;
    
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
    
BEGIN
    execute immediate 'truncate table resumen_auditoria';
    -- Fecha
    for o in c_orden loop
        
        if o.fecha_entrega is not null then
            v_fecha_corte := o.fecha_entrega;
        
        else 
            v_fecha_corte := trunc(sysdate);
        end if;
        
        v_dias_atraso := v_fecha_corte - o.fecha_estimada;
        
        v_dias_estadia_total := v_fecha_corte - o.fecha_recepcion;
        
        if v_dias_atraso <= 0 then
            v_estado := 'En plazo';
        
        elsif v_dias_atraso between 1 and 3 then
            v_estado := 'Atrasado';
        elsif v_dias_atraso between 4 and 7 then
            v_estado := 'Atraso considerable';
        else
            v_estado := 'Sin avances';        
        end if; 
    
    end loop;
    
    -- Stock
    for rep in c_reparacion loop
        v_error := false;
        
        for item in c_repuestos_reparacion(rep.id_reparacion) loop
            begin
                if item.cantidad_utilizada > item.stock_disponible then
                    raise e_stock_insuficiente;
                else 
                    
                    if (item.stock_disponible - item.cantidad_utilizada) <= item.stock_minimo then
                        dbms_output.put_line('Stock pronto a acabarse/acabado');
                    end if;
                    
                end if;

            exception
                when e_stock_insuficiente then
                    v_error := true;
                    insert into log_error (fecha_error, descripcion) values(sysdate, 'Stock insuficiente ' || rep.id_reparacion ||': Repuesto ' || item.nombre_repuesto);                                                         
            end;
        end loop;
        
        if v_error then
            dbms_output.put_line('Reparación ' || rep.id_reparacion || ' procesada con advertencias de stock.');
        end if;
    
    end loop;
    
    -- Total ordenes
    for tot in c_conteo_sucursal loop
        v_resumen.extend;
        
        v_resumen(v_resumen.count).id_sucursal      := tot.id_sucursal;
        v_resumen(v_resumen.count).nombre_sucursal  :=tot.nombre_sucursal;
        v_resumen(v_resumen.count).total_ordenes    :=tot.cantidad;
    end loop;
        
    -- Calculo bono
    for t in c_total_reparaciones loop
        v_bono := 0;
        for b in c_bonos loop
            if t.total between b.min and b.max then
                v_bono := trunc(t.sueldo * (b.porc / 100));
            end if;
        end loop;        
        
        insert into resumen_auditoria (
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
END;
/







    