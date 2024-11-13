#!/bin/bash

# Usar el directorio actual como DIRECTORIO

KO_FOLDER="ko_songs"
URL="https://api.discogs.com/database/search?key=dxtCgfEqswNhHHOaQzxR&secret=ACMIcQrllDbOVpuRmbVHrZCEzNGINTsm"

if ["$1" == ""]; then
    DIRECTORIO="$(pwd)"
else
    DIRECTORIO=$1
fi

IMAGEN_TEMPORAL="$DIRECTORIO/temp_cover.jpeg"

if ["$2" == ""]; then
    MUSIC_ALBUM=""
else
    MUSIC_ALBUM=$2
fi

# Limpiar los nombres de los archivos MP3 en el directorio actual
# (esto se ejecuta fuera del bucle, asegurando que el nombre esté limpio antes de procesarlo)
#rename 's/ \[HQ\]//' "$DIRECTORIO"/*.mp3
#rename -e 's/[0-9]{1,4}\.//' "$DIRECTORIO"/*.mp3
#sleep 20

# Recorre todos los archivos MP3 en el directorio actual

find "$1" -type f -name "*.mp3" | while read -r archivo_mp3; do
    # Extrae el nombre del directorio donde se encuentra el archivo .mp3
    nombre_directorio=$(dirname "$archivo_mp3")
    nombre_directorio_base=$(basename "$nombre_directorio")
    nombre_fichero=$(basename "$archivo_mp3" .mp3)
    artista=$(echo "$nombre_directorio_base" | awk -F ' - ' '{print $1}')
    album=$(echo "$nombre_directorio_base" | awk -F ' - ' '{print $2}')
    cancion=$(echo "$nombre_fichero" | awk -F ' - ' '{print $2}')
    
    # Escapar espacios para URL
    searchSong=$(echo "$album" | sed 's/ /%20/g')  
    searchArtista=$(echo "$artista" | sed 's/ /%20/g')
    searchLabel=$(echo "$2" | sed 's/ /%20/g')


    fullURL="${URL}&artist=${searchArtista}&title=${searchSong}&label=${searchLabel}"
    json=$(curl -s "$fullURL")
    anyo=$(echo "$json" | jq -r ".results[0].year")
    style=$(echo "$json" | jq -r ".results[0].style[0]")
    coverImage=$(echo "$json" | jq -r ".results[0].cover_image")
    
    if [ "$coverImage" == "null" ] || [ -z "$coverImage" ]; 
    then
        eyeD3 --genre $style --title $cancion --album $album --artist $artista --publisher $2 --release-year $anyo --remove-all "$archivo_mp3"
        echo  "${artista} - ${album} - ${cancion} año: ${anyo}, estilo: ${style} - \033[31mNO - PIC\033[0m"
    else
        curl -s -o "$IMAGEN_TEMPORAL" "$coverImage"
        sleep 0.5
        eyeD3 --add-image "$IMAGEN_TEMPORAL:FRONT_COVER" --genre "$style" --title "$cancion" --album "$album" --artist "$artista" --publisher "$2" --release-year "$anyo" --remove-all "$archivo_mp3"
        echo  "${artista} - ${album} - ${cancion} año: ${anyo}, estilo: ${style} - \033[32mOK\033[0m"
        rm "$IMAGEN_TEMPORAL"
    fi
    sleep 1.5
    osascript -e 'tell application "Finder" to set label index of alias POSIX file "/Users/pablo/Desktop/21st century records - 1" to 3'
done

exit 0
