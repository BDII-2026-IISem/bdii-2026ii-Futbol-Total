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
