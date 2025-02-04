#!/bin/bash

# Usar el directorio actual como DIRECTORIO

KO_FOLDER="ko_songs"
URL="https://www.beatport.com/_next/data/EQviIdkYPxv2gxAGmBylh/es/search.json"

if [ -z "$1" ]; then
    DIRECTORIO="$(pwd)"
else
    DIRECTORIO=$1
fi

# Recorre todos los archivos MP3 en el directorio actual
for archivo in "$DIRECTORIO"/*.mp3; do
    # Extrae el nombre del archivo sin extensión    
    # Divide el nombre del archivo en "artista" y "canción" usando " - " como delimitador

    anyo=$(eyeD3 "$archivo" | grep "release date:" | awk -F': ' '{print $2}')

    eyeD3 --recording-date "$anyo" "$archivo"

done

exit 0
