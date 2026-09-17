# Bitácora manual

# Creación de base de datos

## 1.1 Creación de la base de datos MySQL

### Inicio del proceso

Comienzo la creación de la base de datos del proyecto **Pedalibre - Bicicletas compartidas**. Mi objetivo es preparar una base de datos para registrar la operación de un sistema de bicicletas compartidas entre estaciones, incluyendo clientes, bicicletas, estaciones, anclajes, reservas, alquileres, tarifas, penalidades, mantenimientos y pagos.

Trabajaré con cuatro motores de bases de datos: MySQL, PostgreSQL, Microsoft SQL Server y Oracle. Para cada motor crearé la base correspondiente desde DBeaver y, cuando aplique, verificaré el trabajo en su gestor específico. En esta primera etapa me concentraré en MySQL y utilizaré DBeaver para ejecutar los comandos de terminal y comprobar los resultados.

> Por seguridad, las contraseñas y otros datos sensibles de conexión no se incluyen en esta bitácora. Las configuré únicamente en el entorno local de trabajo.

### Evidencia del enunciado

La siguiente captura contiene la narrativa del proyecto, las entidades de negocio, sus atributos sugeridos, las relaciones principales y los módulos funcionales que debo considerar.

![Enunciado del proyecto Pedalibre](Docs/Reguistro%20visual/01-enunciado-proyecto-pedalibre.png)

### Preparación de la base MySQL

Para diferenciar el trabajo realizado en cada herramienta, crearé en el motor MySQL una base de datos llamada `Pedalibre-Terminal-Dbeaver`. En el entorno visual de MySQL Workbench utilizaré el nombre `Pedalibre-Visual-Workbench`. Esta separación me permitirá identificar de dónde proviene cada script y comparar los resultados sin mezclar las pruebas.

Antes de crear las tablas, verificaré lo siguiente:

1. Que el servicio o contenedor de MySQL esté activo.
2. Que DBeaver pueda establecer la conexión con el servidor MySQL.
3. Que la base de datos de trabajo se cree correctamente.
4. Que pueda seleccionar la base de datos y ejecutar consultas sobre ella.

### Creación de la tabla `reserva`

Continué con la creación de la tabla `reserva`, que permite registrar las reservas realizadas por los clientes. La tabla contiene el identificador de la reserva, el cliente relacionado, las fechas de inicio y finalización, el estado y las observaciones.

Para relacionar la reserva con el cliente utilicé el campo `cliente_id` como clave foránea hacia `cliente(id)`. Antes de crear la tabla ajusté el identificador de `cliente` para trabajar con `BIGINT` sin `UNSIGNED`, manteniendo el mismo tipo de dato en la clave primaria y en la clave foránea. La tabla se creó correctamente desde DBeaver y quedó visible en el panel de tablas.

![Creación de la tabla reserva en MySQL](Docs/Reguistro%20visual/07-tabla-reserva-mysql.png)

### Conclusión de la tabla `reserva`

Concluí correctamente la creación de `reserva` y su relación con `cliente`. Esta tabla permite comenzar a representar las operaciones del sistema Pedalibre y mantiene la integridad referencial entre los clientes y sus reservas.

### Creación de la tabla `alquiler`

Después creé la tabla `alquiler`, que registra el inicio y la finalización de los alquileres, el total cobrado, el estado y las observaciones. El campo `referencia_id` relaciona cada alquiler con una reserva existente.

La clave foránea `fk_alquiler_reserva` referencia el campo `id` de la tabla `reserva`. Ejecuté la sentencia desde DBeaver y verifiqué que la tabla apareciera correctamente en el panel de la base de datos.

![Creación de la tabla alquiler en MySQL](Docs/Reguistro%20visual/08-tabla-alquiler-mysql.png)

### Conclusión de la tabla `alquiler`

Concluí correctamente la creación de `alquiler` y establecí su relación con `reserva`. Con esta entidad ya puedo registrar el paso de una reserva a una operación de alquiler dentro del modelo de Pedalibre.

### Creación de la tabla `evento_alquiler`

Continué con la tabla `evento_alquiler`, que permite registrar los eventos asociados a cada alquiler. Incluí el tipo de evento, la fecha, la cantidad, las observaciones y el estado del registro.

Relacioné `evento_alquiler` con `alquiler` mediante el campo `referencia_id` y la clave foránea `fk_evento_alquiler`. La sentencia se ejecutó correctamente en DBeaver y la tabla quedó visible en la base de datos.

![Creación de la tabla evento_alquiler en MySQL](Docs/Reguistro%20visual/09-tabla-evento-alquiler-mysql.png)

### Conclusión de la tabla `evento_alquiler`

Concluí correctamente la creación de `evento_alquiler` y su relación con `alquiler`. Esta entidad permite registrar los diferentes eventos que ocurren durante el ciclo de un alquiler.

### Creación de la tabla `tarifa`

Continué con la creación de la tabla `tarifa`, destinada a almacenar las reglas de cobro del sistema Pedalibre. Incluí el nombre de la tarifa, la regla de cálculo, el valor base, el periodo de vigencia y el estado activo.

La tabla `tarifa` se creó correctamente desde DBeaver y quedó visible dentro de la base de datos `Pedalibre-Terminal-Dbeaver`.

![Creación de la tabla tarifa en MySQL](Docs/Reguistro%20visual/10-tabla-tarifa-mysql.png)

### Conclusión de la tabla `tarifa`

Concluí correctamente la creación de `tarifa`. Esta tabla permitirá definir y mantener las condiciones económicas aplicables a los alquileres del proyecto Pedalibre.

### Creación de la tabla `penalidad`

Continué con la creación de la tabla `penalidad`, destinada a registrar las penalidades generadas durante la operación de los alquileres. Incluí la referencia al alquiler, la fecha, el valor, el estado y las observaciones.

Relacioné `penalidad` con `alquiler` mediante el campo `referencia_id` y la clave foránea `fk_penalidad_alquiler`. La tabla se creó correctamente desde DBeaver y quedó visible en la base de datos.

![Creación de la tabla penalidad en MySQL](Docs/Reguistro%20visual/11-tabla-penalidad-mysql.png)

### Conclusión de la tabla `penalidad`

Concluí correctamente la creación de `penalidad` y su relación con `alquiler`. Esta entidad permitirá controlar los cobros adicionales generados por incumplimientos o situaciones especiales del servicio.

### Creación de la tabla `mantenimiento`

Continué con la creación de la tabla `mantenimiento`, destinada a registrar los mantenimientos programados para las bicicletas. Incluí el recurso relacionado, el tipo de mantenimiento, las fechas programada y de cierre, el costo y el estado.

Durante la creación se presentó un error de incompatibilidad entre la clave foránea `recurso_id` y el campo `bicicleta.id`. Corregí el tipo de `recurso_id` a `BIGINT UNSIGNED` para que coincidiera exactamente con el tipo de la clave primaria de `bicicleta`. Después de realizar este ajuste, la tabla y su relación se crearon correctamente en DBeaver.

![Creación de la tabla mantenimiento en MySQL](Docs/Reguistro%20visual/12-tabla-mantenimiento-mysql.png)

### Conclusión de la tabla `mantenimiento`

Concluí correctamente la creación de `mantenimiento` y establecí su relación con `bicicleta`. También comprobé la importancia de utilizar tipos de datos compatibles entre una clave primaria y su clave foránea para mantener la integridad referencial.

### Creación de la tabla `pago`

Finalicé la creación de las entidades de negocio con la tabla `pago`. Esta tabla registra los pagos realizados en el sistema mediante el tipo de referencia, el identificador de la referencia, el método de pago, el monto, la fecha y el estado.

Utilicé los campos `referencia_tipo` y `referencia_id` para permitir que un pago pueda asociarse con diferentes tipos de operación. La tabla se creó correctamente desde DBeaver y quedó visible junto con las demás entidades de la base de datos.

![Creación de la tabla pago en MySQL](Docs/Reguistro%20visual/13-tabla-pago-mysql.png)

### Conclusión de la tabla `pago`

Concluí correctamente la creación de `pago` y completé las tablas de entidades de negocio definidas para MySQL. La base de datos `Pedalibre-Terminal-Dbeaver` ya cuenta con la estructura inicial necesaria para continuar con la revisión y las pruebas del modelo.

### Revisión del diagrama de relaciones

Después de crear las tablas, abrí el diagrama de la base de datos en DBeaver para revisar visualmente la estructura del modelo. En el diagrama pude observar las entidades creadas y las relaciones establecidas entre `anclaje` y `estacion`, `reserva` y `cliente`, `alquiler` y `reserva`, `evento_alquiler` y `alquiler`, `penalidad` y `alquiler`, `mantenimiento` y `bicicleta`.

Esta revisión me permitió comprobar que las claves foráneas aparecen conectadas con sus respectivas tablas y que la estructura general corresponde con las entidades de negocio definidas para Pedalibre.

![Diagrama de relaciones de MySQL](Docs/Reguistro%20visual/14-diagrama-relaciones-mysql.png)

### Conclusión de la revisión

Concluí la revisión visual del modelo MySQL y confirmé que las tablas creadas se encuentran organizadas en la base de datos `Pedalibre-Terminal-Dbeaver`. El diagrama facilita la comprensión de las relaciones y me servirá como referencia para continuar el trabajo con los demás motores de bases de datos.

## 1.2 Creación de la base de datos MySQL en Workbench

Después de terminar la estructura inicial en DBeaver, continué el proceso desde la terminal para preparar la base de datos que utilizaré en MySQL Workbench. Creé y seleccioné la base `Pedalibre-Visual-Workbench` y comprobé con `SELECT DATABASE()` que la conexión se encontraba trabajando sobre la base correcta.

Al actualizar el panel **SCHEMAS** de MySQL Workbench, la base de datos apareció correctamente junto con las demás bases disponibles. La seleccioné para continuar posteriormente con la creación de las entidades de negocio en este gestor.

![Base de datos MySQL en Workbench](Docs/Reguistro%20visual/15-base-mysql-workbench.png)

### Conclusión

Concluí correctamente la preparación de `Pedalibre-Visual-Workbench`. La base fue creada desde la terminal, verificada mediante SQL y reconocida por MySQL Workbench, por lo que ya puedo comenzar a crear sus tablas en este entorno.

### Creación manual de la tabla `cliente` en Workbench

En MySQL Workbench inicié la creación manual de la tabla `cliente` dentro del esquema `Pedalibre-Visual-Workbench`. Definí sus columnas, seleccioné la clave primaria y configuré el incremento automático del identificador. También establecí los campos obligatorios y el valor predeterminado del estado activo.

![Creación manual de la tabla cliente en Workbench](Docs/Reguistro%20visual/16-tabla-cliente-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `cliente` en MySQL Workbench y dejé lista la estructura para aplicarla al esquema visual del proyecto Pedalibre.

### Creación manual de la tabla `bicicleta` en Workbench

Continué con la definición manual de la tabla `bicicleta` en el esquema `Pedalibre-Visual-Workbench`. Configuré el identificador, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

![Creación manual de la tabla bicicleta en Workbench](Docs/Reguistro%20visual/17-tabla-bicicleta-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `bicicleta` en MySQL Workbench y dejé preparada su estructura para el esquema visual del proyecto Pedalibre.

### Creación manual de la tabla `estacion` en Workbench

Continué con la definición manual de la tabla `estacion` en el esquema `Pedalibre-Visual-Workbench`. Configuré el identificador, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

![Creación manual de la tabla estacion en Workbench](Docs/Reguistro%20visual/18-tabla-estacion-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `estacion` en MySQL Workbench y dejé preparada su estructura para el esquema visual del proyecto Pedalibre.

### Creación manual de la tabla `anclaje` en Workbench

Continué con la definición manual de la tabla `anclaje` en el esquema `Pedalibre-Visual-Workbench`. Configuré sus columnas y establecí la clave foránea `fk_anclaje_estacion`, relacionando `estacion_id` con `estacion.id`.

![Creación manual de la tabla anclaje en Workbench](Docs/Reguistro%20visual/19-tabla-anclaje-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `anclaje` en MySQL Workbench y establecí su relación con `estacion`.

### Creación manual de la tabla `reserva` en Workbench

Continué con la definición manual de la tabla `reserva` en el esquema `Pedalibre-Visual-Workbench`. Configuré sus campos de reserva y establecí la clave foránea `fk_reserva_cliente`, relacionando `cliente_id` con `cliente.id`.

![Creación manual de la tabla reserva en Workbench](Docs/Reguistro%20visual/20-tabla-reserva-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `reserva` en MySQL Workbench y establecí su relación con `cliente`.

### Creación manual de la tabla `alquiler` en Workbench

Continué con la definición manual de la tabla `alquiler` en el esquema `Pedalibre-Visual-Workbench`. Configuré las fechas del alquiler, la referencia a la reserva, el total, el estado y las observaciones. También establecí la clave foránea `fk_alquiler_reserva`, relacionando `referencia_id` con `reserva.id`.

![Creación manual de la tabla alquiler en Workbench](Docs/Reguistro%20visual/21-tabla-alquiler-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `alquiler` en MySQL Workbench y establecí su relación con `reserva`.

### Creación manual de la tabla `evento_alquiler` en Workbench

Continué con la definición manual de la tabla `evento_alquiler` en el esquema `Pedalibre-Visual-Workbench`. Configuré el tipo de evento, la fecha, la cantidad, las observaciones y el estado. También establecí la clave foránea `fk_evento_alquiler`, relacionando `referencia_id` con `alquiler.id`.

![Creación manual de la tabla evento_alquiler en Workbench](Docs/Reguistro%20visual/22-tabla-evento-alquiler-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `evento_alquiler` en MySQL Workbench y establecí su relación con `alquiler`.

### Creación manual de la tabla `tarifa` en Workbench

Continué con la definición manual de la tabla `tarifa` en el esquema `Pedalibre-Visual-Workbench`. Configuré el nombre, la regla de cálculo, el valor base, la vigencia y el estado activo.

![Creación manual de la tabla tarifa en Workbench](Docs/Reguistro%20visual/23-tabla-tarifa-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `tarifa` en MySQL Workbench y dejé preparada su estructura para registrar las condiciones de cobro del proyecto Pedalibre.

### Creación manual de la tabla `penalidad` en Workbench

Continué con la definición manual de la tabla `penalidad` en el esquema `Pedalibre-Visual-Workbench`. Configuré la referencia al alquiler, la fecha, el valor, el estado y las observaciones. También establecí la clave foránea `fk_penalidad_alquiler`, relacionando `referencia_id` con `alquiler.id`.

![Creación manual de la tabla penalidad en Workbench](Docs/Reguistro%20visual/24-tabla-penalidad-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `penalidad` en MySQL Workbench y establecí su relación con `alquiler`.

### Creación manual de la tabla `mantenimiento` en Workbench

Continué con la definición manual de la tabla `mantenimiento` en el esquema `Pedalibre-Visual-Workbench`. Configuré el recurso, el tipo de mantenimiento, las fechas programada y de cierre, el costo y el estado. También establecí la clave foránea `fk_mantenimiento_bicicleta`, relacionando `recurso_id` con `bicicleta.id`.

![Creación manual de la tabla mantenimiento en Workbench](Docs/Reguistro%20visual/25-tabla-mantenimiento-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `mantenimiento` en MySQL Workbench y establecí su relación con `bicicleta`.

### Creación manual de la tabla `pago` en Workbench

Finalicé la definición manual de las tablas de entidades de negocio con la tabla `pago` en el esquema `Pedalibre-Visual-Workbench`. Configuré el tipo de referencia, el identificador de referencia, el método de pago, el monto, la fecha y el estado.

![Creación manual de la tabla pago en Workbench](Docs/Reguistro%20visual/26-tabla-pago-workbench.png)

### Conclusión

Concluí la definición manual de la tabla `pago` en MySQL Workbench y completé las tablas de entidades de negocio del proyecto Pedalibre en este gestor.

### Diagrama final del modelo en Workbench

Finalmente revisé el diagrama del esquema `Pedalibre-Visual-Workbench` en MySQL Workbench. En la vista pude observar las tablas creadas, sus campos principales y las relaciones establecidas entre las entidades del proyecto.

![Diagrama final del modelo en Workbench](Docs/Reguistro%20visual/27-diagrama-workbench.png)

## Conclusión general

Concluí la creación de las bases de datos de MySQL utilizando DBeaver, terminal y MySQL Workbench. Primero preparé la base `Pedalibre-Terminal-Dbeaver`, donde construí las entidades de negocio y verifiqué sus relaciones. Después preparé `Pedalibre-Visual-Workbench` y reproduje manualmente la estructura de las tablas en MySQL Workbench.

Durante el proceso comprendí la importancia de respetar el orden de creación de las tablas, configurar correctamente las claves primarias y utilizar tipos de datos compatibles entre las claves foráneas y sus campos referenciados. El diagrama final me permitió comprobar visualmente la organización del modelo y dejar documentado el avance mediante evidencias de cada etapa.

## 2. PostgreSQL

### 2.1 Creación de la base de datos PostgreSQL en DBeaver

Después de finalizar el trabajo con MySQL, continué con PostgreSQL desde DBeaver. Creé la base de datos `Pedalibre-Terminal-Dbeaver` y comprobé que la conexión la reconociera correctamente. En las propiedades verifiqué que la base utiliza la codificación `UTF8` y que cuenta con el esquema público `public`.

![Creación de la base PostgreSQL en DBeaver](Docs/Reguistro%20visual/28-base-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de `Pedalibre-Terminal-Dbeaver` en PostgreSQL utilizando DBeaver. La base quedó disponible y preparada para continuar con la creación de las tablas de entidades de negocio.

### Creación de la tabla `cliente` en PostgreSQL

Continué con la creación de la tabla `cliente` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí el identificador autogenerado, los datos del documento, el nombre, el teléfono, el correo electrónico y el estado activo del cliente.

![Creación de la tabla cliente en PostgreSQL](Docs/Reguistro%20visual/29-tabla-cliente-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `cliente` en PostgreSQL utilizando DBeaver.

### Creación de la tabla `bicicleta` en PostgreSQL

Continué con la creación de la tabla `bicicleta` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí el identificador autogenerado, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

![Creación de la tabla bicicleta en PostgreSQL](Docs/Reguistro%20visual/30-tabla-bicicleta-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `bicicleta` en PostgreSQL utilizando DBeaver.

### Creación de la tabla `estacion` en PostgreSQL

Continué con la creación de la tabla `estacion` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí el identificador autogenerado, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

![Creación de la tabla estacion en PostgreSQL](Docs/Reguistro%20visual/31-tabla-estacion-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `estacion` en PostgreSQL utilizando DBeaver.

### Creación de la tabla `anclaje` en PostgreSQL

Continué con la creación de la tabla `anclaje` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí el identificador, la estación relacionada, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

También establecí la relación entre `anclaje.estacion_id` y `estacion.id` mediante la clave foránea definida en la tabla.

![Creación de la tabla anclaje en PostgreSQL](Docs/Reguistro%20visual/32-tabla-anclaje-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `anclaje` en PostgreSQL y establecí su relación con `estacion`.

### Creación de la tabla `reserva` en PostgreSQL

Continué con la creación de la tabla `reserva` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí el identificador, el cliente relacionado, las fechas de inicio y finalización, el estado y las observaciones.

La tabla mantiene la relación entre `reserva.cliente_id` y `cliente.id` mediante la clave foránea correspondiente.

![Creación de la tabla reserva en PostgreSQL](Docs/Reguistro%20visual/33-tabla-reserva-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `reserva` en PostgreSQL y establecí su relación con `cliente`.

### Creación de la tabla `alquiler` en PostgreSQL

Continué con la creación de la tabla `alquiler` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí la referencia a la reserva, las fechas de inicio y finalización, el total, el estado y las observaciones.

También establecí la relación entre `alquiler.referencia_id` y `reserva.id` mediante la clave foránea correspondiente.

![Creación de la tabla alquiler en PostgreSQL](Docs/Reguistro%20visual/34-tabla-alquiler-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `alquiler` en PostgreSQL y establecí su relación con `reserva`.

### Creación de la tabla `evento_alquiler` en PostgreSQL

Continué con la creación de la tabla `evento_alquiler` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí la referencia al alquiler, el tipo de evento, la fecha, la cantidad, las observaciones y el estado.

La tabla mantiene la relación entre `evento_alquiler.referencia_id` y `alquiler.id` mediante la clave foránea correspondiente.

![Creación de la tabla evento_alquiler en PostgreSQL](Docs/Reguistro%20visual/35-tabla-evento-alquiler-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `evento_alquiler` en PostgreSQL y establecí su relación con `alquiler`.

### Creación de la tabla `tarifa` en PostgreSQL

Continué con la creación de la tabla `tarifa` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí el nombre de la tarifa, la regla de cálculo, el valor base, el periodo de vigencia y el estado activo.

Configuré `id` como una identidad autogenerada y establecí valores predeterminados para `valor_base` e `is_active`. También dejé `vigencia_hasta` como un campo opcional para permitir tarifas que todavía se encuentren vigentes.

![Creación de la tabla tarifa en PostgreSQL](Docs/Reguistro%20visual/36-tabla-tarifa-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `tarifa` en PostgreSQL y dejé preparada la estructura para administrar los valores y periodos de vigencia de las tarifas del sistema.

### Creación de la tabla `penalidad` en PostgreSQL

Continué con la creación de la tabla `penalidad` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí la relación con `alquiler`, el motivo de la penalidad, el monto, el estado y la fecha de generación.

Configuré `id` como una identidad autogenerada y establecí valores predeterminados para `monto`, `estado` y `fecha_generacion`. La clave foránea `fk_penalidad_alquiler` relaciona cada penalidad con el alquiler correspondiente.

![Creación de la tabla penalidad en PostgreSQL](Docs/Reguistro%20visual/37-tabla-penalidad-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `penalidad` en PostgreSQL y establecí su relación con `alquiler` para registrar y controlar los cargos generados durante el servicio.

### Creación de la tabla `mantenimiento` en PostgreSQL

Continué con la creación de la tabla `mantenimiento` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí la relación con `bicicleta`, el tipo de mantenimiento, la descripción, las fechas de inicio y finalización y el estado del proceso.

Configuré `id` como una identidad autogenerada y dejé `fecha_fin` como un campo opcional para permitir que se registren mantenimientos que todavía estén en curso. También establecí `PENDIENTE` como estado predeterminado.

![Creación de la tabla mantenimiento en PostgreSQL](Docs/Reguistro%20visual/38-tabla-mantenimiento-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `mantenimiento` en PostgreSQL y establecí su relación con `bicicleta` para llevar el control de las intervenciones realizadas sobre cada recurso.

### Creación de la tabla `pago` en PostgreSQL

Continué con la creación de la tabla `pago` dentro del esquema público de `Pedalibre-Terminal-Dbeaver`. Definí la relación con `alquiler`, el monto, el método de pago, el estado, la fecha de pago y la referencia de la transacción.

Configuré `id` como una identidad autogenerada. Dejé `fecha_pago` y `referencia` como campos opcionales, y establecí `PENDIENTE` como estado predeterminado para los pagos que todavía no han sido confirmados.

![Creación de la tabla pago en PostgreSQL](Docs/Reguistro%20visual/39-tabla-pago-postgresql-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `pago` en PostgreSQL y establecí su relación con `alquiler` para registrar y controlar los pagos asociados al servicio.

### Diagrama de relaciones de PostgreSQL en DBeaver

Después de crear las tablas de PostgreSQL, abrí el diagrama del esquema público en DBeaver para revisar visualmente la estructura del modelo. En el diagrama pude comprobar las relaciones entre `anclaje` y `estacion`, `mantenimiento` y `bicicleta`, `evento_alquiler` y `alquiler`, `pago` y `alquiler`, `penalidad` y `alquiler`, `reserva` y `cliente`, y `alquiler` y `reserva`.

La tabla `tarifa` también aparece dentro del modelo y, en esta etapa, se mantiene como una entidad independiente porque no se definió una clave foránea directa con otra tabla.

![Diagrama de relaciones de PostgreSQL en DBeaver](Docs/Reguistro%20visual/40-diagrama-postgresql-dbeaver.png)

### Conclusión de PostgreSQL en DBeaver

Concluí la creación de las tablas de entidades de negocio en PostgreSQL y verifiqué visualmente sus relaciones mediante el diagrama de DBeaver. La estructura cuenta con claves primarias, claves foráneas, campos obligatorios y valores predeterminados, por lo que queda preparada para continuar con la revisión en pgAdmin.

## 3. PostgreSQL en pgAdmin

### 3.1 Base de datos PostgreSQL en pgAdmin

Después de terminar la revisión de PostgreSQL en DBeaver, abrí pgAdmin para continuar con la implementación visual del modelo. En el servidor `Pedalibre` comprobé que existe la base de datos `Pedalibre-Visual-PgAdmin`, que utilizaré para crear y revisar las tablas en este gestor.

![Base de datos PostgreSQL en pgAdmin](Docs/Reguistro%20visual/41-base-postgresql-pgadmin.png)

### Conclusión

Comprobé correctamente la existencia de la base `Pedalibre-Visual-PgAdmin` en pgAdmin. A partir de este punto comenzaré a crear las tablas de entidades de negocio en este gestor, manteniendo la misma estructura definida para PostgreSQL.

### Creación de la tabla `cliente` en pgAdmin

Comencé la creación de las tablas en pgAdmin con la entidad `cliente`. Configuré el identificador autogenerado como clave primaria y definí los campos para el tipo y número de documento, nombre, teléfono, correo electrónico y estado activo.

También marqué como obligatorios los datos necesarios para identificar al cliente y establecí `true` como valor predeterminado para `is_active`.

![Creación de la tabla cliente en pgAdmin](Docs/Reguistro%20visual/42-tabla-cliente-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `cliente` en pgAdmin y dejé preparada la entidad para almacenar la información básica de los usuarios del sistema.

### Creación de la tabla `bicicleta` en pgAdmin

Continué con la creación de la tabla `bicicleta` en la base `Pedalibre-Visual-PgAdmin`. Definí el identificador autogenerado, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

Configuré `nombre` como campo obligatorio, dejé `descripcion` como campo opcional y establecí `true` como valor predeterminado para `is_active`. Las columnas `created_at` y `updated_at` quedaron configuradas para registrar automáticamente la fecha y hora actuales.

![Creación de la tabla bicicleta en pgAdmin](Docs/Reguistro%20visual/43-tabla-bicicleta-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `bicicleta` en pgAdmin y dejé preparada la entidad para controlar los recursos disponibles del sistema.

### Creación de la tabla `estacion` en pgAdmin

Continué con la creación de la tabla `estacion` en la base `Pedalibre-Visual-PgAdmin`. Definí el identificador autogenerado, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

Configuré `nombre` como campo obligatorio, dejé `descripcion` como campo opcional y establecí `true` como valor predeterminado para `is_active`. Las columnas `created_at` y `updated_at` quedaron configuradas para registrar automáticamente la fecha y hora actuales.

![Creación de la tabla estacion en pgAdmin](Docs/Reguistro%20visual/44-tabla-estacion-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `estacion` en pgAdmin y dejé preparada la entidad para registrar los puntos de ubicación del sistema de bicicletas compartidas.

### Creación de la tabla `anclaje` en pgAdmin

Continué con la creación de la tabla `anclaje` dentro de la base `Pedalibre-Visual-PgAdmin`. Definí el identificador autogenerado, la referencia a la estación, el nombre, la descripción, el estado activo y las marcas de tiempo de creación y actualización.

Configuré `estacion_id` como clave foránea hacia `estacion.id`, dejé `nombre` como campo obligatorio y establecí `true` como valor predeterminado para `is_active`.

![Creación de la tabla anclaje en pgAdmin](Docs/Reguistro%20visual/45-tabla-anclaje-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `anclaje` en pgAdmin y dejé preparada la entidad para registrar los puntos físicos disponibles en cada estación.

### Creación de la tabla `reserva` en pgAdmin

Continué con la creación de la tabla `reserva` dentro de la base `Pedalibre-Visual-PgAdmin`. Definí la relación con `cliente`, `bicicleta` y las estaciones de origen y destino, así como la fecha de inicio, la fecha de fin y el estado de la reserva.

Configuré `cliente_id`, `bicicleta_id` y `estacion_origen_id` como campos obligatorios y dejé `estacion_destino_id` como opcional. Además, establecí `ACTIVA` como valor predeterminado para `estado` y registré las fechas de creación y actualización automáticamente.

![Creación de la tabla reserva en pgAdmin](Docs/Reguistro%20visual/46-tabla-reserva-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `reserva` en pgAdmin y dejé preparada la entidad para controlar los ciclos de solicitud y uso de las bicicletas en el sistema.

### Creación de la tabla `alquiler` en pgAdmin

Continué con la creación de la tabla `alquiler` dentro de la base `Pedalibre-Visual-PgAdmin`. Definí la relación con `reserva`, la fecha de inicio, la fecha de fin, la fecha de entrega, el total, el estado y las observaciones del servicio.

Configuré `reserva_id` como clave foránea hacia `reserva.id`, dejé `total` con valor predeterminado `0.00` y mantuve `estado` en un valor inicial de `ACTIVO`. Las columnas de auditoría `created_at` y `updated_at` quedaron habilitadas para registrar la fecha y hora de cada modificación.

![Creación de la tabla alquiler en pgAdmin](Docs/Reguistro%20visual/47-tabla-alquiler-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `alquiler` en pgAdmin y dejé preparada la entidad principal para registrar el uso efectivo de las bicicletas durante cada reserva.

### Creación de la tabla `evento_alquiler` en pgAdmin

Continué con la creación de la tabla `evento_alquiler` dentro de la base `Pedalibre-Visual-PgAdmin`. Definí la relación con `alquiler`, el tipo de evento, la fecha del evento, la cantidad asociada, las observaciones y el estado del registro.

Configuré `alquiler_id` como clave foránea hacia `alquiler.id`, dejé `cantidad` con valor predeterminado `0.00` y establecí `REGISTRADO` como estado inicial para cada evento asociado al servicio.

![Creación de la tabla evento_alquiler en pgAdmin](Docs/Reguistro%20visual/48-tabla-evento-alquiler-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `evento_alquiler` en pgAdmin y dejé preparada la entidad para registrar los cambios y eventos relevantes que ocurren durante cada alquiler.

### Creación de la tabla `tarifa` en pgAdmin

Continué con la creación de la tabla `tarifa` dentro de la base `Pedalibre-Visual-PgAdmin`. Definí la clave primaria, el nombre, la regla de cálculo, el valor base, la vigencia de la tarifa y el estado activo.

Configuré `valor_base` con tipo `numeric(10,2)` y valor predeterminado `0.00`, dejé `vigencia_hasta` como un campo opcional y establecí `true` como valor predeterminado para `is_active`.

![Creación de la tabla tarifa en pgAdmin](Docs/Reguistro%20visual/49-tabla-tarifa-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `tarifa` en pgAdmin y dejé preparada la entidad para definir los precios y condiciones aplicables al sistema de alquileres.

### Creación de la tabla `penalidad` en pgAdmin

Continué con la creación de la tabla `penalidad` dentro de la base `Pedalibre-Visual-PgAdmin`. Definí la relación con `alquiler`, el motivo, el monto, el estado y la fecha de generación de la penalidad.

Configuré `alquiler_id` como clave foránea hacia `alquiler.id`, dejé `monto` con valor predeterminado `0.00` y establecí `PENDIENTE` como valor inicial para el estado de la sanción.

![Creación de la tabla penalidad en pgAdmin](Docs/Reguistro%20visual/50-tabla-penalidad-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `penalidad` en pgAdmin y dejé preparada la entidad para registrar los cargos aplicados por incumplimientos o eventos no previstos durante el servicio.

### Creación de la tabla `mantenimiento` en pgAdmin

Continué con la creación de la tabla `mantenimiento` dentro de la base `Pedalibre-Visual-PgAdmin`. Definí la relación con el recurso, el tipo de mantenimiento, la descripción, las fechas de inicio y fin, y el estado actual del proceso.

Configuré `recurso_id` como referencia al recurso a intervenir, dejé `fecha_fin` como un campo opcional y establecí `PENDIENTE` como valor predeterminado para `estado`.

![Creación de la tabla mantenimiento en pgAdmin](Docs/Reguistro%20visual/51-tabla-mantenimiento-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `mantenimiento` en pgAdmin y dejé preparada la entidad para registrar las intervenciones y revisiones programadas sobre las bicicletas del sistema.

### Creación de la tabla `pago` en pgAdmin

Continué con la creación de la tabla `pago` dentro de la base `Pedalibre-Visual-PgAdmin`. Definí la relación con `alquiler`, el monto, el método de pago, el estado, la fecha de pago y la referencia del comprobante.

Configuré `alquiler_id` como clave foránea hacia `alquiler.id`, dejé `monto` con tipo `numeric(10,2)` y valor predeterminado `0.00`, y establecí `PENDIENTE` como estado inicial para cada transacción aún no confirmada.

![Creación de la tabla pago en pgAdmin](Docs/Reguistro%20visual/52-tabla-pago-postgresql-pgadmin.png)

### Conclusión

Concluí correctamente la creación de la tabla `pago` en pgAdmin y dejé preparada la entidad para registrar la parte financiera asociada a cada alquiler y su respectivo estado de cobro.

### Diagrama de relaciones de PostgreSQL en pgAdmin

Después de terminar la creación de las tablas, revisé el diagrama del esquema en pgAdmin para comprobar la relación entre las entidades principales del proyecto. En la vista visual confirmé que `cliente` se relaciona con `reserva`, que `bicicleta` participa en la reserva y en el mantenimiento, que `estacion` concentra los anclajes, y que `alquiler` conecta los eventos, pagos y penalidades.

El diagrama también deja visible la integración entre reservas, alquileres, tarifas y registros de operación, lo que confirma la coherencia del modelo de negocio para Pedalibre.

![Diagrama final de PostgreSQL en pgAdmin](Docs/Reguistro%20visual/53-diagrama-postgresql-pgadmin.png)

### Conclusión general de PostgreSQL en pgAdmin

Concluí la etapa de PostgreSQL en pgAdmin validando que la base `Pedalibre-Visual-PgAdmin` quedó estructurada con las entidades necesarias para el funcionamiento del sistema. La ejecución de cada tabla, la revisión de sus columnas y la validación visual del diagrama permitieron confirmar que el modelo relacional mantiene consistencia en las relaciones de negocio, en los estados y en los registros de operación.

## 4. SQL Server en DBeaver

### 4.1 Creación de la base de datos SQL Server en DBeaver

Inicié la etapa de SQL Server levantando el motor desde el contenedor `mssql-server`. Después me conecté desde DBeaver y comprobé la creación de la base de datos `Pedalibre-Terminal-Dbeaver`, que utilizaré para definir las tablas de entidades de negocio en este motor.

![Base de datos SQL Server en DBeaver](Docs/Reguistro%20visual/54-base-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la base `Pedalibre-Terminal-Dbeaver` en SQL Server y dejé lista la conexión de DBeaver para comenzar a crear las tablas del modelo.

### Creación de la tabla `cliente` en SQL Server

Continué con la creación de la tabla `cliente` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí el identificador autoincremental como clave primaria, el tipo y número de documento, el nombre, el teléfono, el correo electrónico y el estado activo.

También configuré `numero_documento` como un valor único y establecí `1` como valor predeterminado para `is_active`. La sentencia se ejecutó correctamente y la tabla quedó visible en el esquema `dbo`.

![Creación de la tabla cliente en SQL Server](Docs/Reguistro%20visual/55-tabla-cliente-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `cliente` en SQL Server y dejé preparada la entidad para almacenar la información básica de los usuarios del sistema.

### Creación de la tabla `bicicleta` en SQL Server

Continué con la creación de la tabla `bicicleta` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí el identificador autoincremental, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

Configuré `nombre` como campo obligatorio, dejé `descripcion` como campo opcional y establecí `1` como valor predeterminado para `is_active`. Las columnas de fecha quedaron configuradas con `SYSDATETIME()` para registrar automáticamente la fecha y hora actuales.

![Creación de la tabla bicicleta en SQL Server](Docs/Reguistro%20visual/56-tabla-bicicleta-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `bicicleta` en SQL Server y dejé preparada la entidad para controlar los recursos disponibles del sistema.

### Creación de la tabla `estacion` en SQL Server

Continué con la creación de la tabla `estacion` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí el identificador autoincremental, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

Configuré `nombre` como campo obligatorio, dejé `descripcion` como campo opcional y establecí `1` como valor predeterminado para `is_active`. Las fechas quedaron configuradas con `SYSDATETIME()` para registrar automáticamente la fecha y hora actuales.

![Creación de la tabla estacion en SQL Server](Docs/Reguistro%20visual/57-tabla-estacion-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `estacion` en SQL Server y dejé preparada la entidad para registrar los puntos de ubicación del sistema.

### Creación de la tabla `anclaje` en SQL Server

Continué con la creación de la tabla `anclaje` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí el identificador autoincremental, la estación relacionada, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

Configuré `estacion_id` como clave foránea hacia `estacion.id`, dejé `nombre` como campo obligatorio y establecí `1` como valor predeterminado para `is_active`.

![Creación de la tabla anclaje en SQL Server](Docs/Reguistro%20visual/58-tabla-anclaje-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `anclaje` en SQL Server y establecí su relación con `estacion` para registrar los puntos físicos disponibles en cada ubicación.

### Creación de la tabla `reserva` en SQL Server

Continué con la creación de la tabla `reserva` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí las relaciones con `cliente`, `bicicleta` y las estaciones de origen y destino, junto con las fechas de inicio y fin y el estado de la reserva.

Configuré `cliente_id`, `bicicleta_id` y `estacion_origen_id` como campos obligatorios, dejé `estacion_destino_id` como opcional y establecí `ACTIVA` como valor predeterminado para `estado`. Las claves foráneas quedaron asociadas a las entidades correspondientes.

![Creación de la tabla reserva en SQL Server](Docs/Reguistro%20visual/59-tabla-reserva-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `reserva` en SQL Server y establecí sus relaciones con las entidades de clientes, bicicletas y estaciones.

### Creación de la tabla `alquiler` en SQL Server

Continué con la creación de la tabla `alquiler` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí la relación con `reserva`, las fechas de inicio, fin y entrega, el total del servicio, el estado y las observaciones.

Configuré `reserva_id` como clave foránea hacia `reserva.id`, dejé `total` con valor predeterminado `0.00` y establecí `ACTIVO` como estado inicial. También configuré las fechas de auditoría con `SYSDATETIME()`.

![Creación de la tabla alquiler en SQL Server](Docs/Reguistro%20visual/60-tabla-alquiler-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `alquiler` en SQL Server y establecí su relación con `reserva` para registrar el uso efectivo de cada bicicleta.

### Creación de la tabla `evento_alquiler` en SQL Server

Continué con la creación de la tabla `evento_alquiler` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí la relación con `alquiler`, el tipo de evento, la fecha, la cantidad, las observaciones y el estado del registro.

Configuré `alquiler_id` como clave foránea hacia `alquiler.id`, dejé `cantidad` con valor predeterminado `0.00` y establecí `REGISTRADO` como estado inicial para cada evento.

![Creación de la tabla evento_alquiler en SQL Server](Docs/Reguistro%20visual/61-tabla-evento-alquiler-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `evento_alquiler` en SQL Server y dejé preparada la entidad para registrar los eventos que ocurren durante cada alquiler.

### Creación de la tabla `tarifa` en SQL Server

Continué con la creación de la tabla `tarifa` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí el nombre, la regla de cálculo, el valor base, las fechas de vigencia y el estado activo de cada tarifa.

Configuré `valor_base` con tipo `decimal(10,2)` y valor predeterminado `0.00`, dejé `vigencia_hasta` como un campo opcional y establecí `1` como valor predeterminado para `is_active`.

![Creación de la tabla tarifa en SQL Server](Docs/Reguistro%20visual/62-tabla-tarifa-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `tarifa` en SQL Server y dejé preparada la entidad para definir los precios y periodos de vigencia del servicio.

### Creación de la tabla `penalidad` en SQL Server

Continué con la creación de la tabla `penalidad` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí la relación con `alquiler`, el motivo, el monto, el estado y la fecha de generación de la penalidad.

Configuré `alquiler_id` como clave foránea hacia `alquiler.id`, dejé `monto` con valor predeterminado `0.00` y establecí `PENDIENTE` como estado inicial.

![Creación de la tabla penalidad en SQL Server](Docs/Reguistro%20visual/63-tabla-penalidad-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `penalidad` en SQL Server y dejé preparada la entidad para registrar los cargos derivados de incumplimientos durante el servicio.

### Creación de la tabla `mantenimiento` en SQL Server

Continué con la creación de la tabla `mantenimiento` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí la relación con `bicicleta`, el tipo de mantenimiento, la descripción, las fechas de inicio y fin y el estado del proceso.

Configuré `recurso_id` como clave foránea hacia `bicicleta.id`, dejé `fecha_fin` como un campo opcional y establecí `PENDIENTE` como estado inicial.

![Creación de la tabla mantenimiento en SQL Server](Docs/Reguistro%20visual/64-tabla-mantenimiento-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `mantenimiento` en SQL Server y dejé preparada la entidad para registrar las intervenciones realizadas sobre las bicicletas.

### Creación de la tabla `pago` en SQL Server

Continué con la creación de la tabla `pago` dentro de la base `Pedalibre-Terminal-Dbeaver`. Definí la relación con `alquiler`, el monto, el método de pago, el estado, la fecha de pago y la referencia de la transacción.

Configuré `alquiler_id` como clave foránea hacia `alquiler.id`, dejé `monto` con tipo `decimal(10,2)` y establecí `PENDIENTE` como estado inicial. Los campos `fecha_pago` y `referencia` quedaron como opcionales.

![Creación de la tabla pago en SQL Server](Docs/Reguistro%20visual/65-tabla-pago-sqlserver-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `pago` en SQL Server y dejé preparada la entidad para registrar las transacciones asociadas a cada alquiler.

### Diagrama de relaciones de SQL Server en DBeaver

Después de crear las tablas de SQL Server, abrí el diagrama de la base `Pedalibre-Terminal-Dbeaver` en DBeaver para revisar visualmente la estructura del modelo. En el diagrama confirmé las relaciones entre `cliente`, `reserva`, `bicicleta`, `estacion`, `anclaje`, `alquiler`, `evento_alquiler`, `tarifa`, `penalidad`, `mantenimiento` y `pago`.

La vista también permitió comprobar que las claves foráneas conectan correctamente las entidades operativas y que la tabla `tarifa` se mantiene como una entidad independiente dentro del modelo.

![Diagrama de relaciones de SQL Server en DBeaver](Docs/Reguistro%20visual/66-diagrama-sqlserver-dbeaver.png)

### Conclusión general de SQL Server en DBeaver

Concluí la etapa de SQL Server en DBeaver con las tablas de entidades de negocio, sus claves primarias, sus relaciones y sus restricciones principales. La revisión del diagrama confirmó que la estructura del modelo mantiene coherencia para registrar clientes, bicicletas, estaciones, reservas, alquileres, eventos, mantenimientos, penalidades, pagos y tarifas.

## 5. SQL Server Management Studio

### 5.1 Creación de la base de datos en SQL Server Management Studio

Después de terminar la implementación en DBeaver, abrí SQL Server Management Studio para continuar con la revisión visual del motor. En el explorador de objetos comprobé que la base `Pedalibre-Visual-Management` quedó creada correctamente en el servidor SQL Server.

![Base de datos en SQL Server Management Studio](Docs/Reguistro%20visual/67-base-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la base `Pedalibre-Visual-Management` en SQL Server Management Studio y dejé preparado el entorno para crear las tablas de entidades de negocio en este gestor.

### Creación de la tabla `cliente` en SQL Server Management Studio

Comencé la creación de las tablas en SQL Server Management Studio con la entidad `cliente`. Definí el identificador, el tipo y número de documento, el nombre, el teléfono, el correo electrónico y el estado activo.

La tabla quedó creada dentro del esquema `dbo` y sus columnas muestran los tipos de datos definidos para almacenar la información básica de cada cliente.

![Creación de la tabla cliente en SQL Server Management Studio](Docs/Reguistro%20visual/68-tabla-cliente-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `cliente` en SQL Server Management Studio y dejé preparada la entidad para registrar los usuarios del sistema.

### Creación de la tabla `bicicleta` en SQL Server Management Studio

Continué con la creación de la tabla `bicicleta` en la base `Pedalibre-Visual-Management`. Definí el identificador, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

La tabla quedó creada dentro del esquema `dbo`, con `nombre` como campo obligatorio y `descripcion` como campo opcional. También incluí el estado y las columnas de fecha para conservar el control del recurso.

![Creación de la tabla bicicleta en SQL Server Management Studio](Docs/Reguistro%20visual/69-tabla-bicicleta-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `bicicleta` en SQL Server Management Studio y dejé preparada la entidad para registrar los recursos disponibles del sistema.

### Creación de la tabla `estacion` en SQL Server Management Studio

Continué con la creación de la tabla `estacion` dentro de la base `Pedalibre-Visual-Management`. Definí el identificador, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

La tabla quedó creada dentro del esquema `dbo`, con `nombre` como campo obligatorio y `descripcion` como campo opcional. También incluí el estado y las fechas para controlar la información de cada estación.

![Creación de la tabla estacion en SQL Server Management Studio](Docs/Reguistro%20visual/70-tabla-estacion-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `estacion` en SQL Server Management Studio y dejé preparada la entidad para registrar las ubicaciones del sistema.

### Creación de la tabla `anclaje` en SQL Server Management Studio

Continué con la creación de la tabla `anclaje` dentro de la base `Pedalibre-Visual-Management`. Definí el identificador, la referencia a la estación, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

La tabla quedó creada dentro del esquema `dbo` y `estacion_id` quedó configurado como clave foránea hacia `estacion.id`. El nombre se estableció como obligatorio y la descripción como opcional.

![Creación de la tabla anclaje en SQL Server Management Studio](Docs/Reguistro%20visual/71-tabla-anclaje-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `anclaje` en SQL Server Management Studio y establecí su relación con `estacion` para registrar los puntos disponibles en cada ubicación.

### Creación de la tabla `reserva` en SQL Server Management Studio

Continué con la creación de la tabla `reserva` dentro de la base `Pedalibre-Visual-Management`. Definí las relaciones con `cliente`, `bicicleta` y las estaciones de origen y destino, además de las fechas de inicio y fin y el estado de la reserva.

La tabla quedó creada dentro del esquema `dbo`, con las referencias necesarias para conectar cada reserva con el cliente, la bicicleta y las estaciones correspondientes.

![Creación de la tabla reserva en SQL Server Management Studio](Docs/Reguistro%20visual/72-tabla-reserva-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `reserva` en SQL Server Management Studio y establecí sus relaciones con las entidades que participan en la solicitud del servicio.

### Creación de la tabla `alquiler` en SQL Server Management Studio

Continué con la creación de la tabla `alquiler` dentro de la base `Pedalibre-Visual-Management`. Definí la relación con `reserva`, las fechas de inicio, fin y entrega, el total del servicio, el estado y las observaciones.

La tabla quedó creada dentro del esquema `dbo`, con `reserva_id` como referencia a `reserva.id`, `total` como valor decimal y los campos de auditoría para controlar la creación y actualización del registro.

![Creación de la tabla alquiler en SQL Server Management Studio](Docs/Reguistro%20visual/73-tabla-alquiler-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `alquiler` en SQL Server Management Studio y dejé preparada la entidad para registrar el uso efectivo de las bicicletas.

### Creación de la tabla `evento_alquiler` en SQL Server Management Studio

Continué con la creación de la tabla `evento_alquiler` dentro de la base `Pedalibre-Visual-Management`. Definí la relación con `alquiler`, el tipo de evento, la fecha, la cantidad, las observaciones y el estado del registro.

La tabla quedó creada dentro del esquema `dbo`, con `alquiler_id` como referencia al alquiler correspondiente y los campos necesarios para registrar los eventos operativos del servicio.

![Creación de la tabla evento_alquiler en SQL Server Management Studio](Docs/Reguistro%20visual/74-tabla-evento-alquiler-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `evento_alquiler` en SQL Server Management Studio y dejé preparada la entidad para registrar los eventos asociados a cada alquiler.

### Creación de la tabla `tarifa` en SQL Server Management Studio

Continué con la creación de la tabla `tarifa` dentro de la base `Pedalibre-Visual-Management`. Definí el nombre, la regla de cálculo, el valor base, las fechas de vigencia y el estado activo.

La tabla quedó creada dentro del esquema `dbo`, con `valor_base` como valor decimal y `vigencia_hasta` como campo opcional para permitir tarifas que continúen vigentes.

![Creación de la tabla tarifa en SQL Server Management Studio](Docs/Reguistro%20visual/75-tabla-tarifa-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `tarifa` en SQL Server Management Studio y dejé preparada la entidad para administrar los precios y periodos de vigencia del servicio.

### Creación de la tabla `penalidad` en SQL Server Management Studio

Continué con la creación de la tabla `penalidad` dentro de la base `Pedalibre-Visual-Management`. Definí la relación con `alquiler`, el motivo, el monto, el estado y la fecha de generación.

La tabla quedó creada dentro del esquema `dbo`, con `alquiler_id` como referencia al alquiler correspondiente y los campos necesarios para registrar los cargos derivados del servicio.

![Creación de la tabla penalidad en SQL Server Management Studio](Docs/Reguistro%20visual/76-tabla-penalidad-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `penalidad` en SQL Server Management Studio y dejé preparada la entidad para registrar las sanciones aplicadas a los alquileres.

### Creación de la tabla `mantenimiento` en SQL Server Management Studio

Continué con la creación de la tabla `mantenimiento` dentro de la base `Pedalibre-Visual-Management`. Definí la relación con `bicicleta`, el tipo de mantenimiento, la descripción, las fechas de inicio y fin y el estado del proceso.

La tabla quedó creada dentro del esquema `dbo`, con `recurso_id` como referencia a la bicicleta intervenida y `fecha_fin` como campo opcional para mantenimientos que todavía estén en curso.

![Creación de la tabla mantenimiento en SQL Server Management Studio](Docs/Reguistro%20visual/77-tabla-mantenimiento-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `mantenimiento` en SQL Server Management Studio y dejé preparada la entidad para registrar las revisiones y reparaciones de las bicicletas.

### Creación de la tabla `pago` en SQL Server Management Studio

Continué con la creación de la tabla `pago` dentro de la base `Pedalibre-Visual-Management`. Definí la relación con `alquiler`, el monto, el método de pago, el estado, la fecha de pago y la referencia.

La tabla quedó creada dentro del esquema `dbo`, con `alquiler_id` como referencia al alquiler correspondiente y los campos financieros necesarios para registrar cada transacción.

![Creación de la tabla pago en SQL Server Management Studio](Docs/Reguistro%20visual/78-tabla-pago-sqlserver-management-studio.png)

### Conclusión

Concluí correctamente la creación de la tabla `pago` en SQL Server Management Studio y dejé preparada la entidad para registrar los pagos relacionados con los alquileres.

### Diagrama de relaciones de SQL Server Management Studio

Después de crear las tablas, utilicé el diseñador de diagramas de SQL Server Management Studio para revisar visualmente la estructura de `Pedalibre-Visual-Management`. En el diagrama confirmé las relaciones entre clientes, reservas, bicicletas, estaciones, anclajes, alquileres, eventos, penalidades, mantenimientos y pagos.

La tabla `tarifa` también quedó incluida en el modelo como una entidad independiente, ya que no tiene una clave foránea directa con otra tabla.

![Diagrama de relaciones de SQL Server Management Studio](Docs/Reguistro%20visual/79-diagrama-sqlserver-management-studio.png)

### Conclusión general de SQL Server Management Studio

Concluí la etapa de SQL Server Management Studio con las entidades de negocio creadas y sus relaciones revisadas mediante el diagrama. La estructura permite mantener la integridad de la información y deja preparada la base para continuar posteriormente con el motor Oracle.

## 6. Oracle en DBeaver

### 6.1 Creación del esquema Oracle en DBeaver

Inicié la etapa de Oracle levantando el motor en el contenedor correspondiente y conectándome desde DBeaver mediante el servicio `Pedalibre`. Como Oracle administra la información mediante usuarios y esquemas, creé el usuario `PEDALIBRETERMINALDBEAVER` y le asigné los permisos necesarios para trabajar con las tablas del proyecto.

Después de crear la conexión, comprobé que el esquema aparece en DBeaver con sus carpetas de tablas, vistas, índices y demás objetos disponibles.

![Base de datos Oracle en DBeaver](Docs/Reguistro%20visual/80-base-oracle-dbeaver.png)

### Conclusión

Concluí correctamente la configuración del esquema `PEDALIBRETERMINALDBEAVER` en Oracle y dejé preparada la conexión de DBeaver para comenzar a crear las tablas del modelo.

### Creación de la tabla `cliente` en Oracle

Continué con la creación de la tabla `cliente` dentro del esquema `PEDALIBRETERMINALDBEAVER`. Definí el identificador como una identidad autogenerada, el tipo y número de documento, el nombre, el teléfono, el correo electrónico y el estado activo.

La sentencia se ejecutó correctamente y la tabla quedó visible en el esquema de trabajo de Oracle.

![Creación de la tabla cliente en Oracle](Docs/Reguistro%20visual/81-tabla-cliente-oracle-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `cliente` en Oracle y dejé preparada la entidad para registrar la información básica de los usuarios del sistema.

### Creación de la tabla `bicicleta` en Oracle

Continué con la creación de la tabla `bicicleta` dentro del esquema `PEDALIBRETERMINALDBEAVER`. Definí el identificador como una identidad autogenerada, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

La sentencia se ejecutó correctamente y la tabla quedó visible en el esquema de trabajo de Oracle, con los campos de auditoría configurados para registrar la fecha y hora actuales.

![Creación de la tabla bicicleta en Oracle](Docs/Reguistro%20visual/82-tabla-bicicleta-oracle-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `bicicleta` en Oracle y dejé preparada la entidad para administrar los recursos disponibles del sistema.

### Creación de la tabla `estacion` en Oracle

Continué con la creación de la tabla `estacion` dentro del esquema `PEDALIBRETERMINALDBEAVER`. Definí el identificador como una identidad autogenerada, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

La sentencia se ejecutó correctamente y la tabla quedó disponible en el esquema de Oracle para registrar las ubicaciones del sistema.

![Creación de la tabla estacion en Oracle](Docs/Reguistro%20visual/83-tabla-estacion-oracle-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `estacion` en Oracle y dejé preparada la entidad para registrar las estaciones del sistema de bicicletas compartidas.

### Creación de la tabla `anclaje` en Oracle

Continué con la creación de la tabla `anclaje` dentro del esquema `PEDALIBRETERMINALDBEAVER`. Definí el identificador como una identidad autogenerada, la referencia a la estación, el nombre, la descripción, el estado activo y las fechas de creación y actualización.

La sentencia se ejecutó correctamente y la clave foránea `fk_anclaje_estacion` quedó configurada para relacionar `estacion_id` con `estacion.id`.

![Creación de la tabla anclaje en Oracle](Docs/Reguistro%20visual/84-tabla-anclaje-oracle-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `anclaje` en Oracle y establecí su relación con `estacion` para registrar los puntos disponibles en cada ubicación.

### Creación de la tabla `reserva` en Oracle

Continué con la creación de la tabla `reserva` dentro del esquema `PEDALIBRETERMINALDBEAVER`. Definí las relaciones con `cliente`, `bicicleta` y las estaciones de origen y destino, además de las fechas de inicio y fin y el estado de la reserva.

La sentencia se ejecutó correctamente y las claves foráneas quedaron configuradas para mantener la relación entre la reserva y las entidades involucradas.

![Creación de la tabla reserva en Oracle](Docs/Reguistro%20visual/85-tabla-reserva-oracle-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `reserva` en Oracle y establecí sus relaciones con clientes, bicicletas y estaciones.

### Creación de la tabla `alquiler` en Oracle

Continué con la creación de la tabla `alquiler` dentro del esquema `PEDALIBRETERMINALDBEAVER`. Definí la relación con `reserva`, las fechas de inicio, fin y entrega, el total, el estado y las observaciones.

La sentencia se ejecutó correctamente y la clave foránea `fk_alquiler_reserva` quedó configurada para relacionar `reserva_id` con `reserva.id`.

![Creación de la tabla alquiler en Oracle](Docs/Reguistro%20visual/86-tabla-alquiler-oracle-dbeaver.png)

### Conclusión

Concluí correctamente la creación de la tabla `alquiler` en Oracle y establecí su relación con `reserva` para registrar el uso efectivo de cada bicicleta.
