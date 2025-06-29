#!/usr/bin/env bash
# -*- ENCODING: UTF-8 -*-

## GL1 Tarea 1 - Script 1
## Script en shell para cargar y desmontar módulos del kernel

# colores de las letras 
VERDE='\033[0;32m' ROJO='\033[0;31m'
SC='\033[0m' # normal, sin color

# Opciones : montar o desmontar el módulo 
echo " ¿Qué acción deseas realizar? (montar/desmontar):"
read ACCION
# Comprobamos si la acción es válida  
if [ "$ACCION" != "montar" ] && [ "$ACCION" != "desmontar" ] && [ "$ACCION" != "Montar" ] && [ "$ACCION" != "Desmontar" ]; then
    echo -e "${ROJO} Acción no válida. ${SC} Debes elegir 'montar' o 'desmontar'."
    exit 1
fi

# montar modulo 
if [ "$ACCION" == "montar" ] || [ "$ACCION" == "Montar" ]; then
    echo "Introduce el nombre del módulo que deseas montar:"
    read MODULO
    #Comprobamos si ya está montado
    if lsmod | grep "$MODULO" &> /dev/null; then
        echo "El módulo $MODULO ya está montado."
        exit 0
    else 
        # Montamos el módulo
        sudo modprobe -v $MODULO
        if [ $? -eq 0 ]; then
            echo -e "${VERDE} El módulo $MODULO se ha cargado correctamente. ${SC}]"
        else
            echo -e "${ROJO} Error al cargar el módulo $MODULO. ${SC}"
            exit 1
        fi
    fi

# desmontar modulo
elif [ "$ACCION" == "desmontar" ] || [ "$ACCION" == "Desmontar" ]; then
    echo "Introduce el nombre del módulo que deseas desmontar:"
    read MODULO
    # Comprobamos si està montado
    if ! lsmod | grep "$MODULO" &> /dev/null; then
        echo "El módulo $MODULO no está montado."
        exit 0
    else 
        # Desmontamos el módulo
        sudo modprobe -vr $MODULO
        if [ $? -eq 0 ]; then
            echo -e "${VERDE} El módulo $MODULO se ha desmontado correctamente. ${SC}"
        else
            echo -e "${ROJO}Error al desmontar el módulo $MODULO. ${SC} Revisa si el módulo está en uso o si tienes permisos suficientes."
            exit 1
        fi
    fi
else 
    echo "Acción no válida. Debes elegir 'montar' o 'desmontar'."
    exit 1
fi
