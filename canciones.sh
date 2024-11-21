#!/bin/bash

# Usar el directorio actual como DIRECTORIO

KO_FOLDER="ko_songs"
URL="https://api.discogs.com/database/search?key=dxtCgfEqswNhHHOaQzxR&secret=ACMIcQrllDbOVpuRmbVHrZCEzNGINTsm"

if [ -z "$1" ]; then
    DIRECTORIO="$(pwd)"
else
    DIRECTORIO=$1
fi

if [ -z "$2" ]; then
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
    titlecaseSong=$(echo "$cancion" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

    # Escapar espacios para URL
    searchSong=$(echo "$cancion" | sed 's/ /%20/g')  
    searchArtista=$(echo "$artista" | sed 's/ /%20/g')

    # Construir la URL completa
    fullURL="${URL}&artist=${searchArtista}&title=${searchSong}"
    json=$(curl -s "$fullURL")
    index=$(echo "$json" | jq -r '(.results | to_entries | map(select(.value.format | contains(["Vinyl", "12\""]))) | .[0] | .key) // 0
')
    results=$(echo "$json" | jq ".pagination.items")
    anyo=$(echo "$json" | jq -r ".results[${index}].year")
    style=$(echo "$json" | jq -r ".results[${index}].style[0]")
    coverImage=$(echo "$json" | jq -r ".results[${index}].cover_image")

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
    if [ $results -gt 0 ];
    then
            curl -s -o "$IMAGEN_TEMPORAL" "$coverImage"
            sleep 0.5
            eyeD3 --add-image "$IMAGEN_TEMPORAL:FRONT_COVER" --genre "$style" --title "$titlecaseSong" --release-year "$anyo" "$archivo"
            rm "$IMAGEN_TEMPORAL"
        
    else
            eyeD3 --title "$titlecaseSong" --album "$album" --artist "$artista" --publisher "$2" --remove-all "$archivo"
            mv "$archivo" "$DIRECTORIO/$KO_FOLDER/"
            no_encontrados+=("${artista} - ${album}")
    fi
    sleep 1.5
done

echo "\nArchivos NO encontrados en Discogs:"
for item in "${no_encontrados[@]}"; do
    echo "- $item"
done

exit 0
