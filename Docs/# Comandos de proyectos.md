# Comandos de proyectos

## Crear los proyectos y asignar permisos

```bash
cd ~/ia-lab
mkdir -p "projecs/base de datos 2" "projecs/desarrollo web"
chmod -R 777 projecs
```

## Entrar al proyecto Base de Datos 2

```bash
cd ~/ia-lab/projecs/"base de datos 2"
```

## Entrar al proyecto Desarrollo Web

```bash
cd ~/ia-lab/projecs/"desarrollo web"
```

## Volver a la carpeta principal

```bash
cd ~/ia-lab
```

## Ver los proyectos

```bash
cd ~/ia-lab/projecs
ls -la
```

## Ver los proyectos en forma de árbol

```bash
tree ~/ia-lab/projecs
```

## Alternativa si `tree` no está instalado

```bash
find ~/ia-lab/projecs -maxdepth 2 -type d
```