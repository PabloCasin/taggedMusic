#!/bin/bash

# Directorio de trabajo (por defecto, el actual)
DIR="${1:-.}"

# Verifica si el directorio existe
if [[ ! -d "$DIR" ]]; then
    echo "❌ El directorio no existe: $DIR"
    exit 1
fi

# Dependencias necesarias
command -v ffprobe >/dev/null 2>&1 || { echo "Error: ffprobe no encontrado. Instala ffmpeg."; exit 1; }
command -v ffplay >/dev/null 2>&1 || { echo "Error: ffplay no encontrado. Instala ffmpeg."; exit 1; }
command -v eyeD3 >/dev/null 2>&1 || { echo "Error: eyeD3 no encontrado. Instálalo con: brew install eye-d3"; exit 1; }

# Función para reproducir fragmentos
play_segments() {
    local FILE="$1"
    local DURATION="$2"

    local POS1=$(echo "$DURATION * 0.25" | bc)
    local POS2=$(echo "$DURATION * 0.33" | bc)
    local POS3=$(echo "$DURATION * 0.50" | bc)
    local POS4=$(echo "$DURATION * 0.66" | bc)
    local POS5=$(echo "$DURATION * 0.75" | bc)

    echo "🎧 Reproduciendo fragmentos de: $FILE"
    ffplay -nodisp -autoexit -t 3 -ss "$POS1" "$FILE" >/dev/null 2>&1
    ffplay -nodisp -autoexit -t 3 -ss "$POS2" "$FILE" >/dev/null 2>&1
    ffplay -nodisp -autoexit -t 3 -ss "$POS3" "$FILE" >/dev/null 2>&1
    ffplay -nodisp -autoexit -t 3 -ss "$POS4" "$FILE" >/dev/null 2>&1
    ffplay -nodisp -autoexit -t 3 -ss "$POS5" "$FILE" >/dev/null 2>&1
}

# Buscar archivos MP3 sin comentarios (manejo correcto de espacios y caracteres especiales)
FILES=()
TOTAL_FILES=0
TAGGED_FILES=0

# Crear un archivo temporal con la lista de archivos
find "$DIR" -type f -name "*.mp3" -print0 > /tmp/mp3list.txt

# Leer línea por línea manejando correctamente los espacios y caracteres especiales
while IFS= read -r -d '' FILE; do
    COMMENT=$(eyeD3 --no-color "$FILE" | grep "^Comment:")
    if [[ -z "$COMMENT" ]]; then
        FILES+=("$FILE")
        ((TOTAL_FILES++))
    fi
done < /tmp/mp3list.txt

# Eliminar el archivo temporal después de usarlo
rm -f /tmp/mp3list.txt

# Si no hay archivos sin comentarios, salir
if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "✅ No hay archivos MP3 sin comentarios en $DIR"
    exit 0
fi

# Procesar cada archivo encontrado
for ((i = 0; i < TOTAL_FILES; i++)); do
    FILE="${FILES[$i]}"
    echo "📂 Procesando: $FILE"
    echo "📊 Progreso: $((i+1)) de $TOTAL_FILES archivos"

    # Obtener duración del archivo en segundos
    DURATION=$(ffprobe -i "$FILE" -show_entries format=duration -v quiet -of csv="p=0")

    if [[ -z "$DURATION" || "$DURATION" == "N/A" ]]; then
        echo "⚠️ No se pudo obtener la duración del archivo."
        continue
    fi

    while true; do
        play_segments "$FILE" "$DURATION"

        # Pedir entrada del usuario
        echo "🎵 ¿Qué tipo de canción es?"
        echo "   C - Cantada"
        echo "   M - Melodía instrumental"
        echo "   B - Base instrumental"
        echo "   S - Saltar sin etiquetar"
        echo "   R - Re-escuchar la canción"
        read -s -n1 KEY
        echo ""

        # Si presiona 'R', repetir reproducción
        if [[ "$KEY" == "R" || "$KEY" == "r" ]]; then
            echo "🔁 Repitiendo fragmentos..."
            continue
        fi

        # Determinar el comentario según la tecla presionada
        case "$KEY" in
            C|c) COMMENT="(C)" ;;
            M|m) COMMENT="(M)" ;;
            B|b) COMMENT="(B)" ;;
            S|s) echo "⏭️ Saltado: $FILE"; break ;;
            *) echo "⚠️ Opción inválida. Intenta de nuevo."; continue ;;
        esac

        # Escribir el comentario en el archivo
        eyeD3 --comment "$COMMENT" "$FILE"
        ((TAGGED_FILES++))
        echo "✅ Guardado en el comentario ID3: $COMMENT"
        echo "🏷️ Archivos tageados: $TAGGED_FILES / $TOTAL_FILES"
        break
    done

    echo "--------------------------------------"
done

echo "🎉 Proceso completado: $TAGGED_FILES de $TOTAL_FILES archivos etiquetados."
