# BDY1103

# TecnoFix - Gestión de Servicios Técnicos

Base de datos para la gestión de servicios técnicos de **TecnoFix**, empresa dedicada al diagnóstico, reparación y mantenimiento de equipos tecnológicos.

## 📋 Descripción

El proyecto consiste en el diseño e implementación de una base de datos utilizando **Oracle Database y PL/SQL**.

La base de datos permite almacenar y relacionar información sobre:

* Clientes
* Equipos
* Órdenes de servicio
* Reparaciones
* Técnicos
* Especialidades
* Repuestos
* Sucursales
* Estados de las órdenes
* Marcas y modelos

El objetivo es facilitar el control de las reparaciones, el uso de repuestos y la información relacionada con las órdenes de servicio.

## 🛠️ Tecnologías utilizadas

* **Oracle Database**
* **PL/SQL**
* SQL

## 🗂️ Estructura de la base de datos

Las principales tablas utilizadas en el proyecto son:

| Tabla                | Descripción                                |
| -------------------- | ------------------------------------------ |
| `cliente`            | Información de los clientes                |
| `equipo`             | Equipos ingresados al servicio técnico     |
| `marca`              | Marcas de los equipos                      |
| `modelo`             | Modelos asociados a una marca              |
| `tipo_dispositivo`   | Tipos de equipos                           |
| `orden`              | Órdenes de servicio                        |
| `estado_orden`       | Estados de las órdenes                     |
| `reparacion`         | Información de las reparaciones            |
| `tecnico`            | Técnicos encargados de las reparaciones    |
| `especialidad`       | Especialidades de los técnicos             |
| `repuesto`           | Repuestos disponibles                      |
| `repuesto_utilizado` | Repuestos utilizados en cada reparación    |
| `sucursal`           | Sucursales de TecnoFix                     |
| `comuna`             | Comunas donde se encuentran las sucursales |

La base de datos utiliza claves primarias y foráneas para mantener las relaciones entre las diferentes entidades.

## 📊 Datos de prueba

El proyecto incluye datos ficticios para realizar pruebas y representar diferentes situaciones de la operación de TecnoFix.

Se incluyen datos de clientes, técnicos, sucursales, equipos, órdenes, reparaciones y repuestos.

## ⚙️ Instalación

### 1. Crear la base de datos

Abrir **Oracle Database** y conectarse al esquema donde se ejecutará el proyecto.

### 2. Ejecutar el script

Ejecutar el script SQL del proyecto en el siguiente orden:

1. Eliminación de tablas existentes.
2. Creación de las tablas.
3. Inserción de datos de prueba.
4. Ejecución de los procedimientos, funciones o procesos PL/SQL incluidos en el proyecto.

### 3. Verificar los datos

Una vez ejecutado el script, se pueden realizar consultas SQL sobre las tablas para revisar la información almacenada.

## 🎯 Objetivos del proyecto

* Organizar la información de TecnoFix.
* Mantener la integridad de los datos.
* Controlar las órdenes de servicio y sus estados.
* Registrar las reparaciones realizadas.
* Controlar el uso y disponibilidad de repuestos.
* Obtener información útil para apoyar la operación.
* Automatizar y controlar procesos mediante PL/SQL.

## 👥 Proyecto

**Asignatura:** BDY1103 - Taller de Base de Datos

**Tecnología principal:** Oracle Database + PL/SQL

**Caso:** TecnoFix - Gestión Inteligente de Servicios Técnicos
