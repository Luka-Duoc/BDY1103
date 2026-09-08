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

insert into marca (nombre_marca) values ('Dell');
insert into marca (nombre_marca) values ('Lenovo');
insert into marca (nombre_marca) values ('HP');
insert into marca (nombre_marca) values ('Apple');
insert into marca (nombre_marca) values ('Asus');
insert into marca (nombre_marca) values ('Epson');
insert into marca (nombre_marca) values ('Acer');
insert into marca (nombre_marca) values ('Samsung');
insert into marca (nombre_marca) values ('Brother');
insert into marca (nombre_marca) values ('Toshiba');

insert into tipo_dispositivo (nombre, descripcion) values ('Notebook', 'Equipo portatil de uso personal o corporativo');
insert into tipo_dispositivo (nombre, descripcion) values ('Desktop', 'Computador de escritorio torre tradicional');
insert into tipo_dispositivo (nombre, descripcion) values ('All-in-One', 'Equipo de escritorio integrado en pantalla');
insert into tipo_dispositivo (nombre, descripcion) values ('Servidor Rack', 'Servidor corporativo para montaje en gabinete');
insert into tipo_dispositivo (nombre, descripcion) values ('Monitor', 'Pantalla externa para estaciones de trabajo');
insert into tipo_dispositivo (nombre, descripcion) values ('Impresora', 'Dispositivo de impresion termica o inyeccion');
insert into tipo_dispositivo (nombre, descripcion) values ('Workstation', 'Estacion de trabajo para diseno o renderizado');
insert into tipo_dispositivo (nombre, descripcion) values ('Tablet', 'Dispositivo portatil tactil multiproposito');

insert into comuna (nombre_comuna) values ('Santiago');
insert into comuna (nombre_comuna) values ('Providencia');
insert into comuna (nombre_comuna) values ('Las Condes');
insert into comuna (nombre_comuna) values ('La Florida');
insert into comuna (nombre_comuna) values ('Maipu');
insert into comuna (nombre_comuna) values ('Nunoa');
insert into comuna (nombre_comuna) values ('San Miguel');
insert into comuna (nombre_comuna) values ('Macul');
insert into comuna (nombre_comuna) values ('Puente Alto');
insert into comuna (nombre_comuna) values ('Huechuraba');

insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (18452369, '4', 'Matias', 'Gonzalez', 987654321, 'mgonzalez@gmail.com', 'Av. Providencia 1345');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (15987452, 'K', 'Camila', 'Silva', 976543210, 'csilva.consultora@outlook.com', 'Los Leones 220 Depto 402');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (19321456, '8', 'Rodrigo', 'Perez', 965432109, 'rodrigo.perez@empresa.cl', 'Av. Apoquindo 4500');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (17654982, '1', 'Valentina', 'Rojas', 954321098, 'vrojas.diseno@gmail.com', 'Vicuna Mackenna 7200');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (16234890, '3', 'Sebastian', 'Munoz', 943210987, 'smunoz.ing@gmail.com', 'Av. Pajaritos 3100');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (14567123, '7', 'Francisca', 'Morales', 932109876, 'fmorales.abogada@gmail.com', 'Irarrazaval 2400');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (20123789, '2', 'Diego', 'Castro', 921098765, 'dcastro.dev@yahoo.com', 'Gran Avenida 5100');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (76234891, '5', 'Inversiones', 'Tecnologicas SpA', 912345678, 'contacto@invertec.cl', 'El Golf 40 Piso 12');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (13890456, '9', 'Alejandro', 'Vargas', 981234567, 'avargas.arq@gmail.com', 'Quilin 3400');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (17123987, '6', 'Loreto', 'Fernandez', 972345678, 'lfernandez.psico@gmail.com', 'Pedro Fontova 6200');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (77564120, '3', 'Servicios', 'Logisticos Central', 963456789, 'soporte@logcentral.cl', 'Americo Vespucio 1020');
insert into cliente (rut_cliente, dv_rut, nombre, apellido, telefono, correo, direccion) values (18890234, '5', 'Gabriel', 'Santander', 954567890, 'gsantander@hotmail.com', 'Concha y Toro 150');

insert into estado_orden (nombre, descripcion) values ('Recibido', 'Orden ingresada en sucursal a la espera de evaluacion');
insert into estado_orden (nombre, descripcion) values ('Pendiente de diagnostico', 'Equipo en cola asignado o por asignar a tecnico');
insert into estado_orden (nombre, descripcion) values ('Diagnosticado', 'Diagnostico tecnico emitido a la espera de presupuesto');
insert into estado_orden (nombre, descripcion) values ('Esperando aprobacion', 'Presupuesto enviado al cliente pendiente de respuesta');
insert into estado_orden (nombre, descripcion) values ('Esperando repuesto', 'Reparacion pausada por falta de insumo o importacion');
insert into estado_orden (nombre, descripcion) values ('En reparacion', 'Trabajo mecanico o electronico en ejecucion');
insert into estado_orden (nombre, descripcion) values ('Reparacion finalizada', 'Equipo reparado y con control de calidad aprobado');
insert into estado_orden (nombre, descripcion) values ('Entregado', 'Equipo devuelto conforme al cliente con orden cerrada');
insert into estado_orden (nombre, descripcion) values ('Reparacion rechazada', 'Presupuesto no aceptado o equipo catalogado como irreparable');
insert into estado_orden (nombre, descripcion) values ('Cancelado', 'Servicio anulado antes de iniciar trabajos tecnicos');

insert into especialidad (nombre_especialidad, descripcion) values ('Microelectronica', 'Reparacion de placas madre y circuitos smd');
insert into especialidad (nombre_especialidad, descripcion) values ('Sistemas y Software', 'Recuperacion forense de datos y configuracion so');
insert into especialidad (nombre_especialidad, descripcion) values ('Hardware General', 'Cambio de partes mecanicas pantallas y mantencion');
insert into especialidad (nombre_especialidad, descripcion) values ('Equipos de Impresion', 'Calibracion de cabezales y sistemas de arrastre');
insert into especialidad (nombre_especialidad, descripcion) values ('Servidores y Redes', 'Mantenimiento de storage fuentes redundantes y raid');

insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('SSD NVMe 1TB Kingston', 'Unidad m.2 PCIe Gen 4 corporativo', 18, 5);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Pantalla LED 15.6 FHD', 'Display 30 pines compatible Dell y HP', 8, 3);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Memoria RAM DDR4 16GB 3200MHz', 'Modulo sodimm para estaciones de trabajo', 24, 6);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Pasta Termica Noctua 3.5g', 'Compuesto termico de alta conductividad', 20, 5);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Bateria A1965 Apple', 'Modulo recargable original MacBook Air', 2, 4);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Cabezal de Impresion Epson L Series', 'Repuesto cabezal micropiezo inyeccion continua', 5, 2);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Teclado retroiluminado Lenovo', 'Teclado idioma espanol linea ThinkPad E14', 11, 3);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Fuente de Poder ATX 650W Bronze', 'Unidad de alimentacion certificada desktop', 6, 2);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('SSD SATA 480GB Crucial', 'Unidad estado solido 2.5 pulgadas', 15, 4);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Memoria RAM DDR5 16GB 4800MHz', 'Modulo sodimm nueva generacion portatil', 7, 3);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Cooler Disipador HP Pavilion', 'Ventilador interno original linea gaming', 4, 2);
insert into repuesto (nombre_repuesto, descripcion, stock_disponible, stock_minimo) values ('Kit Rodillos Arrastre Brother', 'Gomas de alimentacion de papel multiproposito', 9, 3);

insert into bono_equipos_reparados (rango_minimo, rango_maximo, porc_bono) values (1, 5, 3);
insert into bono_equipos_reparados (rango_minimo, rango_maximo, porc_bono) values (6, 10, 5);
insert into bono_equipos_reparados (rango_minimo, rango_maximo, porc_bono) values (11, 20, 7);
insert into bono_equipos_reparados (rango_minimo, rango_maximo, porc_bono) values (21, 999, 10);

insert into modelo (nombre_modelo, id_marca) values ('Latitude 5420', 1);
insert into modelo (nombre_modelo, id_marca) values ('ThinkPad E14 Gen 3', 2);
insert into modelo (nombre_modelo, id_marca) values ('ProBook 450 G8', 3);
insert into modelo (nombre_modelo, id_marca) values ('MacBook Air M1', 4);
insert into modelo (nombre_modelo, id_marca) values ('EcoTank L3250', 6);
insert into modelo (nombre_modelo, id_marca) values ('OptiPlex 7090 Desktop', 1);
insert into modelo (nombre_modelo, id_marca) values ('ZenBook 14 UX425', 5);
insert into modelo (nombre_modelo, id_marca) values ('Aspire 5 A515', 7);
insert into modelo (nombre_modelo, id_marca) values ('DCP-T720DW', 9);
insert into modelo (nombre_modelo, id_marca) values ('PowerEdge R440', 1);
insert into modelo (nombre_modelo, id_marca) values ('MacBook Pro M2 14', 4);
insert into modelo (nombre_modelo, id_marca) values ('Pavilion Gaming 15', 3);

insert into sucursal (nombre_sucursal, direccion, telefono, id_comuna) values ('Sucursal Santiago Centro', 'Moneda 1140 Local 4', 933445566, 1);
insert into sucursal (nombre_sucursal, direccion, telefono, id_comuna) values ('Sucursal Providencia', 'Av. Pedro de Valdivia 520', 922334455, 2);
insert into sucursal (nombre_sucursal, direccion, telefono, id_comuna) values ('Sucursal Las Condes', 'Av. Manquehue Sur 350', 944556677, 3);
insert into sucursal (nombre_sucursal, direccion, telefono, id_comuna) values ('Sucursal La Florida', 'Av. Froilan Roa 1200', 955667788, 4);
insert into sucursal (nombre_sucursal, direccion, telefono, id_comuna) values ('Sucursal Maipu', 'Av. Pajaritos 2050', 966778899, 5);
insert into sucursal (nombre_sucursal, direccion, telefono, id_comuna) values ('Sucursal Huechuraba', 'Av. del Parque 4100', 977889900, 10);

insert into tecnico (rut, dv_run, nombre, apellido, telefono, correo, direccion, estado, id_especialidad, sueldo) 
values (16789452, '3', 'Carlos', 'Mendoza', 981122334, 'cmendoza.tec@tecnofix.cl', 'San Diego 890', 'Activo', 1, 850000);
insert into tecnico (rut, dv_run, nombre, apellido, telefono, correo, direccion, estado, id_especialidad, sueldo) 
values (18234567, '9', 'Daniela', 'Munoz', 972233445, 'dmunoz.tec@tecnofix.cl', 'Gran Avenida 4300', 'Activo', 3, 920000);
insert into tecnico (rut, dv_run, nombre, apellido, telefono, correo, direccion, estado, id_especialidad, sueldo) 
values (17456789, '5', 'Esteban', 'Paredes', 963344556, 'eparedes.tec@tecnofix.cl', 'Tobalaba 1450', 'Activo', 2, 780000);
insert into tecnico (rut, dv_run, nombre, apellido, telefono, correo, direccion, estado, id_especialidad, sueldo) 
values (15890123, '1', 'Patricia', 'Arancibia', 954455667, 'parancibia.tec@tecnofix.cl', 'Macul 2100', 'Activo', 4, 810000);
insert into tecnico (rut, dv_run, nombre, apellido, telefono, correo, direccion, estado, id_especialidad, sueldo) 
values (14785236, '9', 'Andres', 'Salazar', 945566778, 'asalazar.tec@tecnofix.cl', 'Rosas 1820', 'Inactivo', 3, 750000);
insert into tecnico (rut, dv_run, nombre, apellido, telefono, correo, direccion, estado, id_especialidad, sueldo) 
values (19012874, '2', 'Javier', 'Contreras', 936677889, 'jcontreras.tec@tecnofix.cl', 'Av. La Florida 8900', 'Activo', 5, 870000);
insert into tecnico (rut, dv_run, nombre, apellido, telefono, correo, direccion, estado, id_especialidad, sueldo) 
values (16450912, '8', 'Beatriz', 'Pena', 927788990, 'bpena.tec@tecnofix.cl', 'Santa Isabel 450', 'Activo', 1, 890000);
insert into tecnico (rut, dv_run, nombre, apellido, telefono, correo, direccion, estado, id_especialidad, sueldo) 
values (17892341, '4', 'Gonzalo', 'Tapia', 918899001, 'gtapia.tec@tecnofix.cl', 'Vespucio Norte 120', 'Activo', 3, 830000);

insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Notebook no enciende tras descarga en puerto usb', 1, 1);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Notebook con display quebrado por presion en mochila', 3, 1);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Portatil corporativo con lentitud y reinicios constantes', 2, 1);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Notebook no retiene carga se apaga sin cargador', 4, 1);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Impresora con atasco reiterado y mala calidad de color', 5, 6);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Desktop se apaga repentinamente al exigir carga de trabajo', 6, 2);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Notebook con teclas pegadas por derrame de liquido', 2, 1);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Portatil ultrabook sin imagen en pantalla', 7, 1);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Servidor no bootea tras corte de suministro electrico', 10, 4);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Notebook gaming con sobrecalentamiento y ruidos en ventilador', 12, 1);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Impresora multifuncional no tracciona hojas de bandeja', 9, 6);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('MacBook reinicia continuamente en bucle de manzana', 11, 1);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Notebook economico con disco danado y sectores defectuosos', 8, 1);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Workstation torre con pantalla azul de memoria ram', 6, 7);
insert into equipo (descripcion, id_modelo, id_tipo_dispositivo) values ('Notebook corporativo requiere ampliacion de storage', 1, 1);

insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-01', date '2026-08-05', date '2026-08-05', 'Revision de linea vdd en placa madre', 1, 8, 1, 1);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-03', date '2026-08-07', date '2026-08-08', 'Reemplazo de modulo de pantalla fhd', 2, 8, 2, 2);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-10', date '2026-08-14', date '2026-08-13', 'Mantencion termica profunda y limpieza interna', 3, 8, 1, 3);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-12', date '2026-08-18', date '2026-08-20', 'Diagnostico de celdas y reemplazo de bateria', 4, 7, 3, 4);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-15', date '2026-08-22', date '2026-08-25', 'Desarme y calibracion de inyectores piezo', 5, 6, 4, 5);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-18', date '2026-08-23', date '2026-08-26', 'Pruebas de estres de fuente de poder atx', 6, 5, 1, 6);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-20', date '2026-08-24', date '2026-08-25', 'Limpieza quimica de teclado y ensamble', 7, 7, 2, 7);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-22', date '2026-08-27', date '2026-08-29', 'Cambio de disipador y thermal pads', 9, 6, 4, 10);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-24', date '2026-08-28', date '2026-08-30', 'Sustitucion de rodillo y mantenimiento', 11, 7, 5, 11);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-25', date '2026-08-28', date '2026-09-02', 'Revision circuito inversor de iluminacion', 1, 6, 3, 8);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-26', date '2026-08-30', date '2026-09-03', 'Reparacion de pistas y recuperacion de boot', 10, 9, 2, 12);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-27', date '2026-08-30', date '2026-09-04', 'Diagnostico raid y recuperacion de volumen', 8, 3, 1, 9);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-28', date '2026-09-01', date '2026-09-03', 'Migracion a disco solido y mantencion', 12, 6, 5, 13);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-29', date '2026-09-03', date '2026-09-05', 'Testeo de bancos de ram y reemplazo', 8, 2, 6, 14);
insert into orden (fecha_recepcion, fecha_estimada, fecha_entrega, descripcion, id_cliente, id_estado_orden, id_sucursal, id_equipo) values (date '2026-08-30', date '2026-09-04', date '2026-09-06', 'Upgrade de almacenamiento corporativo', 3, 1, 3, 15);

insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-02', date '2026-08-04', 'Mosfet entrada quemado', 'Reemplazo de componente mosfet de 19v y bypass de proteccion', 1, 1);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-04', date '2026-08-07', 'Panel fhd quebrado', 'Instalacion de repuesto original y prueba de tasas de refresco', 2, 2);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-11', date '2026-08-12', 'Compuesto termico solidificado', 'Limpieza profunda de disipador y sustitucion de pasta termica', 3, 2);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-13', date '2026-08-17', 'Bateria con celdas hinchadas', 'Sustitucion de bateria macbook y calibracion de ciclo smc', 4, 1);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-16', date '2026-08-21', 'Cabezal con conductos tapados', 'Desobstruccion por ultrasonido y reemplazo de cabezal epson', 5, 4);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-19', date '2026-08-22', 'Riel de 12v con caida de voltaje', 'Desmontaje de fuente defectuosa a la espera de stock de reemplazo', 6, 2);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-21', date '2026-08-23', 'Teclas pegadas con sulfato', 'Montaje de nuevo teclado thinkpad y pruebas de continuidad', 7, 2);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-23', date '2026-08-26', 'Cooler con rodamiento quebrado', 'Instalacion de cooler nuevo original hp y repasteo', 8, 8);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-25', date '2026-08-27', 'Rodillo gastado y deformado', 'Cambio kit arrastre brother y calibracion de sensores opticos', 9, 4);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-26', date '2026-08-29', 'Circuito backlight desoldado', 'Microsoldadura en conector fpc de pantalla asus', 10, 7);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-27', date '2026-08-29', 'Corrupcion nand irreversible', 'Revision de pistas en placa logica sin posibilidad de salvar nand', 11, 7);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-28', date '2026-08-31', 'Disco mecanico con sectores', 'Clonacion hacia disco solido sata e instalacion interna', 13, 3);
insert into reparacion (fecha_inicio, fecha_finalizacion, diagnostico, descripcion, id_orden, id_tecnico) values (date '2026-08-30', date '2026-09-01', 'Modulo ram con fallas de paridad', 'Sustitucion de memoria ddr4 de 16gb y prueba memtest86', 14, 6);

insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (1, 4, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (2, 2, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (3, 4, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (4, 5, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (5, 6, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (7, 7, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (8, 4, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (8, 11, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (9, 12, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (12, 9, 1);
insert into repuesto_utilizado (id_reparacion, id_repuesto, cantidad_utilizada) values (13, 3, 1);

