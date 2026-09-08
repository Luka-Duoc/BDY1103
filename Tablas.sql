drop table repuesto_utilizado cascade constraints;
drop table reparacion cascade constraints;
drop table orden cascade constraints;
drop table equipo cascade constraints;
drop table modelo cascade constraints;
drop table sucursal cascade constraints;
drop table tecnico cascade constraints;
drop table repuesto cascade constraints;
drop table marca cascade constraints;
drop table tipo_dispositivo cascade constraints;
drop table cliente cascade constraints;
drop table comuna cascade constraints;
drop table estado_orden cascade constraints;
drop table especialidad cascade constraints;
drop table bono_equipos_reparados cascade constraints;
drop table log_error cascade constraints;

create table marca (
    id_marca number(10) generated always as identity primary key,
    nombre_marca varchar2(100) not null
);

create table tipo_dispositivo (
    id_tipo_dispositivo number(10) generated always as identity primary key,
    nombre varchar2(100) not null,
    descripcion varchar2(200) not null
);

create table comuna (
    id_comuna number(10) generated always as identity primary key,
    nombre_comuna varchar2(100) not null
);

create table cliente (
    id_cliente number(10) generated always as identity primary key,
    rut_cliente number(8) not null,
    dv_rut char(1) not null,
    nombre varchar2(100) not null,
    apellido varchar2(100) not null,
    telefono number(9) not null,
    correo varchar2(100) not null unique,
    direccion varchar2(100)
);

create table estado_orden (
    id_estado number(10) generated always as identity primary key,
    nombre varchar2(100) not null,
    descripcion varchar2(200) not null
    
);

create table especialidad (
    id_especialidad number(10) generated always as identity primary key,
    nombre_especialidad varchar2(100) not null,
    descripcion varchar2(200) not null
);

create table repuesto (
    id_repuesto number(10) generated always as identity primary key,
    nombre_repuesto varchar2(100) not null,
    descripcion varchar(200) not null,
    stock_disponible number(10),
    stock_minimo number(10)
);

create table log_error (
    id_error number(10) generated always as identity primary key,
    fecha_error date not null,
    descripcion varchar2(200) not null
);

create table bono_equipos_reparados (
    id_cantidad_equipos number(10) generated always as identity primary key,
    rango_minimo number(5) not null,
    rango_maximo number(5) not null,
    porc_bono number(10) not null
);

create table modelo (
    id_modelo number(10) generated always as identity primary key,
    nombre_modelo varchar2(100) not null,
    id_marca number(10) not null,

    constraint fk_marca foreign key (id_marca) references marca (id_marca)
);

create table sucursal (
    id_sucursal number(10) generated always as identity primary key,
    nombre_sucursal varchar2(100) not null,
    direccion varchar2(200) not null,
    telefono number(9) not null,
    id_comuna number(10) not null,
    
    constraint fk_comuna foreign key (id_comuna) references comuna (id_comuna)
);

create table tecnico (
    id_tecnico number(10) generated always as identity primary key,
    rut number(8) not null,
    dv_run char(1) not null,
    nombre varchar2(100) not null,
    apellido varchar2(100) not null,
    telefono number(9) not null,
    correo varchar2(100) not null unique,
    sueldo number(10) not null,
    direccion varchar2(200) not null,
    estado varchar2(100) not null,
    id_especialidad number(10) not null,
    
    constraint fk_especialidad foreign key (id_especialidad) references especialidad (id_especialidad)
);

create table equipo (
    id_equipo number(10) generated always as identity primary key,
    descripcion varchar2(200),
    id_modelo number(10) not null,
    id_tipo_dispositivo number(10) not null,
    
    constraint fk_modelo foreign key (id_modelo) references modelo (id_modelo),
    constraint fk_tipo_dispositivo foreign key (id_tipo_dispositivo) references tipo_dispositivo (id_tipo_dispositivo)
);

create table orden (
    id_orden number(10) generated always as identity primary key,
    fecha_recepcion date not null,
    fecha_estimada date not null,
    fecha_entrega date not null,
    descripcion varchar2(200) not null,
    id_cliente number(10) not null,
    id_estado_orden number(10) not null,
    id_sucursal number(10) not null,
    id_equipo number(10) not null,
    
    constraint fk_cliente foreign key (id_cliente) references cliente (id_cliente),
    constraint fk_estado_orden foreign key (id_estado_orden) references estado_orden (id_estado),
    constraint fk_sucursal foreign key (id_sucursal) references sucursal (id_sucursal),
    constraint fk_equipo foreign key (id_equipo) references equipo (id_equipo)
);


create table reparacion (
    id_reparacion number(10) generated always as identity primary key,
    fecha_inicio date not null,
    fecha_finalizacion date not null,
    diagnostico varchar2(30) not null,
    descripcion varchar2(200) not null,
    id_orden number(10) not null,
    id_tecnico number(10) not null,
    
    constraint fk_orden foreign key (id_orden) references orden (id_orden),
    constraint fk_tecnico foreign key (id_tecnico) references tecnico (id_tecnico)
);

create table repuesto_utilizado (
    id_repuesto_utilizado number(10) generated always as identity primary key,
    id_reparacion number(10) not null,
    id_repuesto number(10) not null,
    cantidad_utilizada number(4) not null,
    
    constraint fk_rep_util_reparacion foreign key (id_reparacion) references reparacion (id_reparacion),
    constraint fk_repuesto foreign key (id_repuesto) references repuesto (id_repuesto)
);

create table resumen_auditoria(
    id_resumen        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    fecha_proceso     DATE DEFAULT SYSDATE,
    id_tecnico        NUMBER,
    nombre_tecnico    VARCHAR2(100),
    reparaciones      NUMBER,
    sueldo_base       NUMBER(10, 2),
    monto_bono        NUMBER(10, 2),
    sueldo_total      NUMBER(10, 2)
);

create table entrega_producto(
    id_entrega number generated always as identity primary key,
    id_orden number not null,
    fecha_recepcion date not null,
    fecha_estimada date not null,
    fecha_entrega date not null,
    id_estado_orden number not null,
    
    constraint fk_orden_producto foreign key (id_orden) references orden(id_orden),
    constraint fk_estado foreign key(id_estado_orden) references estado_orden(id_estado)
);

create table resumen_sucursal(
    id_resumen_sucursal number(10) generated always as identity primary key,
    id_sucursal number(10) not null,
    nombre_sucursal varchar2(100) not null,
    total_reparaciones number(10) not null,
    
    constraint fk_re_sucursal foreign key (id_sucursal) references sucursal(id_sucursal)
);
