#!/bin/bash

# Usar el directorio actual como DIRECTORIO

KO_FOLDER="ko_songs"
URL="https://api.discogs.com/database/search?key=dxtCgfEqswNhHHOaQzxR&secret=ACMIcQrllDbOVpuRmbVHrZCEzNGINTsm"

if [$1 == ""]; then
    DIRECTORIO="$(pwd)"
else
    DIRECTORIO=$1
fi

if [$2 == ""]; then
    MUSIC_ALBUM=""
else
    MUSIC_ALBUM=$2
fi

echo "${DIRECTORIO} \n ${MUSIC_ALBUM}" 

# Limpiar los nombres de los archivos MP3 en el directorio actual
# (esto se ejecuta fuera del bucle, asegurando que el nombre esté limpio antes de procesarlo)
#rename 's/ \[HQ\]//' "$DIRECTORIO"/*.mp3
#rename -e 's/[0-9]{1,4}\.//' "$DIRECTORIO"/*.mp3
#sleep 20

# Crea la carpeta KO_FOLDER si no existe
if [ ! -d "$KO_FOLDER" ]; then
    mkdir "$KO_FOLDER"
fi

# Recorre todos los archivos MP3 en el directorio actual
for archivo in "$DIRECTORIO"/*.mp3; do
    # Extrae el nombre del archivo sin extensión
    nombre_archivo=$(basename "$archivo" .mp3)
    
    # Divide el nombre del archivo en "artista" y "canción" usando " - " como delimitador
    artista=$(echo "$nombre_archivo" | awk -F ' - ' '{print $1}')
    cancionyRemix=$(echo "$nombre_archivo" | awk -F ' - ' '{print $2}')
    cancion=$(echo "$cancionyRemix" | awk -F '(' '{print $1}')
    
    # Escapar espacios para URL
    searchSong=$(echo "$cancion" | sed 's/ /%20/g')  
    searchArtista=$(echo "$artista" | sed 's/ /%20/g')

    # Construir la URL completa
    fullURL="${URL}&artist=${searchArtista}&title=${searchSong}"
    json=$(curl -s "$fullURL")
    anyo=$(echo "$json" | jq -r ".results[0].year")
    style=$(echo "$json" | jq -r ".results[0].style[0]")

    # Establece los tags de artista y título
    if [ "$anyo" == "null" ] || [ "$style" == "null" ]; then
        # Si la información es incompleta, mover el archivo a KO_FOLDER
        id3v2 --artist "$artista" --song "$cancionyRemix" --album "$MUSIC_ALBUM" "$archivo"
        mv "$archivo" "$KO_FOLDER/"
        echo  "${artista} - ${cancionyRemix} año: ${anyo}, estilo: ${style} - \033[31mKO\033[0m"
    else
        id3v2 --artist "$artista" --song "$cancionyRemix" --album "$MUSIC_ALBUM" --year "$anyo" --genre "$style" "$archivo"
        echo  "${artista} - ${cancionyRemix} año: ${anyo}, estilo: ${style} - \033[32mOK\033[0m"

    fi

    # Pausa de 1.5 segundos
    sleep 1.5
done

exit 0
