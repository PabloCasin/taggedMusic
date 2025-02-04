#!/bin/bash

# Usar el directorio actual como DIRECTORIO

KO_FOLDER="ko_songs"
URL="https://www.beatport.com/_next/data/EQviIdkYPxv2gxAGmBylh/es/search.json"

if [ -z "$1" ]; then
    DIRECTORIO="$(pwd)"
else
    DIRECTORIO=$1
fi
IMAGEN_TEMPORAL="$DIRECTORIO/temp_cover.jpeg"
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

    artista_completo=$(eyeD3 "$archivo" | grep "title:" | awk -F': ' '{print $2}')

    # Obtener solo el texto antes del primer paréntesis
    artista=$(echo "$artista_completo" | sed -E 's/ *\(.*//')

    # Extraer el PRIMER contenido entre paréntesis (como el mix)
    mix=$(echo "$artista_completo" | grep -oE '\(.*?\)' | head -n 1 | sed 's/[()]//g')

    # Convertir el contenido de 'mix' a minúsculas
    mix=$(echo "$mix" | tr '[:upper:]' '[:lower:]')

    # Extraer el artista desde el ID3 tag
    cancion=$(eyeD3 "$archivo" | grep "artist:" | awk -F': ' '{print $2}')

    # Escapar espacios para URL
    searchSong=$(echo "$cancion" | sed 's/ /%20/g')  
    searchArtista=$(echo "$artista" | sed 's/ /%20/g')
    searchMix=$(echo "$mix" | sed 's/ /%20/g')
    query="${searchArtista}+${searchSong}+${searchMix}"

    # Construir la URL completa
    fullURL="${URL}?q=${query}"
    json=$(curl -s "$fullURL")
    data=$(echo "$json" | jq -r ".pageProps.dehydratedState.queries[0].state.data.tracks.data[0]")

    newArtist=$(echo "$data" | jq -r ".artists[0].artist_name")
    newTitle=$(echo "$data" | jq -r ".track_name")
    newMix=$(echo "$data" | jq -r ".mix_name")
    newBpm=$(echo "$data" | jq -r ".bpm")
    newYear=$(echo "$data" | jq -r ".release_date")
    newYear=$(echo "$newYear" | cut -c 1-4)
    newStyle=$(echo "$data" | jq -r ".genre[0].genre_name")
    newImage=$(echo "$data" | jq -r ".release.release_image_uri")
    newLabel=$(echo "$data" | jq -r ".label.label_name")
    newAllTitle=$(echo "${newTitle} (${newMix})")
    
    curl -s -o "$IMAGEN_TEMPORAL" "$newImage"
    sleep 0.5
    eyeD3 --artist "$newArtist" --title "$newAllTitle" --bpm "$newBpm" --album "Beatport" --recording-date "$newYear" --genre "$newStyle" --add-image "$IMAGEN_TEMPORAL:FRONT_COVER" --publisher "$newLabel" --remove-all "$archivo"
    rm "$IMAGEN_TEMPORAL"
    # Pausa de 1.5 segundos
    sleep 1.5
done

exit 0
