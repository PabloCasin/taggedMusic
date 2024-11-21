#!/bin/bash

# Usar el directorio actual como DIRECTORIO

KO_FOLDER="ko_songs"
URL="https://api.discogs.com/database/search?key=dxtCgfEqswNhHHOaQzxR&secret=ACMIcQrllDbOVpuRmbVHrZCEzNGINTsm"

if [ -z "$1" ]; then
    DIRECTORIO="$(pwd)"
else
    DIRECTORIO=$1
fi
echo "$DIRECTORIO/$KO_FOLDER/"
IMAGEN_TEMPORAL="$DIRECTORIO/temp_cover.jpeg"

if [ -z "$2" ]; then
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

    artista=$(eyeD3 "$archivo_mp3" | grep "artist:" | awk -F': ' '{print $2}')
    album=$(eyeD3 "$archivo_mp3" | grep "album:" | awk -F': ' '{print $2}')
    cancion=$(eyeD3 "$archivo_mp3" | grep "title:" | awk -F': ' '{print $2}')

    # Escapar espacios para URL
    searchSong=$(echo "$album" | sed -e 's/ /%20/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\//%2F/g')  
    searchArtista=$(echo "$artista" | sed -e 's/ /%20/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\//%2F/g')
    searchLabel=$(echo "$2" | sed -e 's/ /%20/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\//%2F/g')


    fullURL="${URL}&artist=${searchArtista}&title=${searchSong}&label=${searchLabel}"
    json=$(curl -s "$fullURL")
    index=$(echo "$json" | jq -r '(.results | to_entries | map(select(.value.format | contains(["Vinyl", "12\""]))) | .[0] | .key) // 0
')
    results=$(echo "$json" | jq ".pagination.items")
    anyo=$(echo "$json" | jq -r ".results[${index}].year")
    style=$(echo "$json" | jq -r ".results[${index}].style[0]")
    coverImage=$(echo "$json" | jq -r ".results[${index}].cover_image")
    
    if [ $results -gt 0 ];
    then
            curl -s -o "$IMAGEN_TEMPORAL" "$coverImage"
            sleep 0.5
            eyeD3 --add-image "$IMAGEN_TEMPORAL:FRONT_COVER" --genre "$style" --release-year "$anyo" "$archivo_mp3"
            rm "$IMAGEN_TEMPORAL"
        
    else

            fullURL="${URL}&title=${searchSong}&label=${searchLabel}"
            json=$(curl -s "$fullURL")
            index=$(echo "$json" | jq -r '(.results | to_entries | map(select(.value.format | contains(["Vinyl", "12\""]))) | .[0] | .key) // 0
        ')
            results=$(echo "$json" | jq ".pagination.items")
            anyo=$(echo "$json" | jq -r ".results[${index}].year")
            style=$(echo "$json" | jq -r ".results[${index}].style[0]")
            coverImage=$(echo "$json" | jq -r ".results[${index}].cover_image")

            if [ $results -gt 0 ]; then
                curl -s -o "$IMAGEN_TEMPORAL" "$coverImage"
                sleep 0.5
                eyeD3 --add-image "$IMAGEN_TEMPORAL:FRONT_COVER" --genre "$style" --release-year "$anyo" "$archivo_mp3"
                rm "$IMAGEN_TEMPORAL"
            else
                eyeD3  --genre "$style" --release-year "$anyo" "$archivo_mp3"
                mv "$archivo_mp3" "$DIRECTORIO/$KO_FOLDER/"
                no_encontrados+=("${artista} - ${album}")
            fi
    fi
    sleep 1.5
done

echo "\nArchivos NO encontrados en Discogs:"
for item in "${no_encontrados[@]}"; do
    echo "- $item"
done

exit 0