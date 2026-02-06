# Ruby on Records

```text
` ♫⋆｡♪.✧₊˚♬⋆♭ ´   ______      _                          ______                       _
 ` _________ ´   | ___ \    | |                         | ___ \                     | |
` /_|_____|_\ ´  | |_/ /   _| |__  _   _    ___  _ __   | |_/ /___  ___ ___  _ __ __| |___
  '. \   / .'    |    / | | | '_ \| | | |  / _ \| '_ \  |    // _ \/ __/ _ \| '__/ _` / __|
    '.\ /.'      | |\ \ |_| | |_) | |_| | | (_) | | | | | |\ \  __/ (_| (_) | | | (_| \__ \
      '.'        \_| \_\__,_|_.__/ \__, |  \___/|_| |_| \_| \_\___|\___\___/|_|  \__,_|___/
                                    __/ |
                                    |___/
```

## Descripción

Una aplicación de gestión de inventario pensado para una disquería que vende CDs y vinilos, tanto nuevos como usados.
La aplicación permitirá al personal del negocio administrar el stock de productos y asentar ventas. Además, incluirá una página pública que permita al público ver el catálogo de discos que la tienda ofrece.

## Requisitos técnicos

* Ruby 3.4.5
* Rails 8.1.1
* SQLite3

#### Para instalar la aplicación y sus dependencias:

```bash
  git clone git@github.com:holafrank/ruby_on_records.git
  cd ruby_on_records

  # Instalar dependencias
  bundle install
```

#### Para poblar la base de datos:

```bash
  # Para crear y migrar la base de datos por primera vez
  rails db:create
  rails db:migrate
  rails db:seed

  # Para borrar y volver a poblar la base de datos nuevamente
  rails db:reset
  rails db:seed
```

#### Para levantar la aplicación localmente:

```bash
  cd ruby_on_records
  rails s
  # Acceder a http://localhost:3000/ desde un navegador
  # Para detener la ejecución de la aplicación usar Ctrl-Z
```
