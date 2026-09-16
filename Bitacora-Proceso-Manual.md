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

