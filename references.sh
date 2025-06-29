#!/usr/bin/env bash
# -*- ENCODING: UTF-8 -*-

## GL1 Tarea 1 - Script 2
## Almacena referencias a archivos, imprime la direccion de los archivos referenciados y agrega/elimina referencias.

#Almacenamos las referencias en un directorio ~/.referencias
if [ -f ~/.referencias/ref.txt ]; then
    touch ~/.referencias/ref.txt
    mkdir -p ~/.referencias
fi

echo -e "\033[0;32m Que deseas hacer ? \033[0m"
echo "1. Imprimir la dirección de los archivos referenciados almacenados en ref.txt"
echo "2. Agregar una nueva referencia."
echo "3. Eliminar una referencia."
echo "4. Cambiar el permiso de una referencia."
echo "5. Salir."
read -p "Selecciona una opción (1-5): " opcion

case $opcion in
    1) 
        echo -e "\033[1;34m Dirección de los archivos referenciados: \033[0m"
        referencias=$(wc -l < ~/.referencias/ref.txt)
        # Si no hay referencias, entonces imprime el error
        if [ "$referencias" -eq 0 ]; then
            echo -e "\033[0;31m No hay referencias almacenadas. \033[0m"
        else
            echo -e "\033[1;33m---------------------------------------------\033[0m"
            while IFS= read -r linea; do
                echo -e "\033[1;36m$linea\033[0m"
            done < ~/.referencias/ref.txt
            echo -e "\033[1;33m---------------------------------------------\033[0m"
            echo -e "\033[1;32m Total de referencias: $referencias \033[0m"
        fi
        ;;
    2) 
        # Agregar una nueva referencia
        read -p "Ingresa la dirección del archivo a agregar: " direccion
        # Obtenemos el nombre del archivo desde la dirección
        nombre_archivo=$(basename "$direccion")
        directorio_referencias="$HOME/.referencias" # *obs :Usamos la variable $HOME para asegurar la ruta al directorio de inicio
        nombre_enlace="$directorio_referencias/ref_${nombre_archivo}"

        # Verifica si ya existe un enlace con el mismo nombre
        if [ -e "$nombre_enlace" ]; then
            echo -e "\033[0;31m Ya existe una referencia a $nombre_archivo. \033[0m"
        elif [ "$direccion" == "/" -o "$direccion" == "/boot" -o "$direccion" == "~" -o -z "$direccion" ]; then
            echo -e "\033[0;31m No se puede agregar la dirección. \033[0m Verifica si es una ruta valida y no irrumpe en la seguridad del sistema."
        elif [ "$direccion" == "/dev/sda" -o "$direccion" == "/dev/sdb" ]; then
            echo -e "\033[0;31m No se puede agregar la dirección. \033[0m Verifica si es un dispositivo externo."
        else
            if [ -e "$direccion" ]; then
                ln -s "$direccion" "$nombre_enlace"
                # Guardar el nombre de la referencia y la ruta del archivo o directorio al que apunta el enlace
                echo "ref_${nombre_archivo} -> ${direccion}" >> ~/.referencias/ref.txt
                if [ $? -eq 0 ]; then
                    echo -e "\033[0;32m La dirección se ha agregado a las referencias. \033[0m"
                else
                    echo -e "\033[0;31m Error al crear el enlace simbólico. \033[0m"
                fi
            else
                echo -e "\033[0;31m La dirección no existe. \033[0m"
            fi
        fi
        ;;
    3) 
        # Eliminar una referencia
        read -p "Ingresa el nombre de la referencia a eliminar (recuerda que las referencias se guardan en formato ref_{nombre}): " nombre_archivo
        directorio_referencias="$HOME/.referencias"
        nombre_enlace="$directorio_referencias/${nombre_archivo}"
        if [ -L "$nombre_enlace" ]; then
            # Eliminar el enlace simbólico
            rm "$nombre_enlace"
            # Eliminar la línea correspondiente en ref.txt
            sed -i "/^${nombre_archivo} -> /d" "$directorio_referencias/ref.txt"
            echo -e "\033[0;32m La referencia a $nombre_archivo ha sido eliminada. \033[0m"
        else
            echo -e "\033[0;31m La referencia '$nombre_archivo' no existe en las referencias. \033[0m"
        fi
        ;;
    4)
        # Cambiar el permiso de una referencia
        read -p "Ingresa el nombre de la referencia a cambiar permiso: " nombre_referencia
        ruta_enlace="$HOME/.referencias/${nombre_referencia}"
        if [ -e "$ruta_enlace" ]; then
            ruta_original=$(readlink -f "$ruta_enlace")
            # Verifica si la ruta original existe
            if [ -e "$ruta_original" ]; then
                read -p "Ingresa el nuevo permiso (ejemplo: 755): " permiso
                # Validar formato del permiso
                if [[ "$permiso" =~ ^[0-7]{3,4}$ ]]; then 
                    sudo chmod "$permiso" "$ruta_original"
                    echo -e "\033[0;32m El permiso de '$ruta_original' se ha cambiado. \033[0m"
                else
                    echo -e "\033[0;31m Formato de permiso inválido. Use 3 o 4 dígitos. \033[0m"
                fi
            else
                echo -e "\033[0;31m El archivo original referenciado no existe: '$ruta_original'. \033[0m"
            fi
        else
            echo -e "\033[0;31m No existe una referencia con el nombre '$nombre_referencia'. \033[0m"
        fi
        ;;
    5)
        # Salir
        echo -e "\033[0;32m Saliendo... \033[0m"
        exit 0
        ;;
    *)
        # Opción no válida
        echo -e "\033[0;31m Opción no válida. \033[0m"
        ;;
esac