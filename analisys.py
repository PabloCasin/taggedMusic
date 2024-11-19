import os
import sys
import numpy as np
import librosa
import json

# Configuración de parámetros
SAMPLE_RATE = 22050  # Frecuencia de muestreo común en librosa
N_MFCC = 13  # Número de coeficientes MFCC

def extract_mfcc(file_path, n_mfcc=N_MFCC):
    """Extrae los MFCCs promedio de un archivo de audio."""
    y, sr = librosa.load(file_path, sr=SAMPLE_RATE)
    mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=n_mfcc)
    mfcc_mean = np.mean(mfcc.T, axis=0)
    return mfcc_mean

def process_all_files(data_path):
    """Procesa todos los archivos .mp3 en el directorio especificado de forma recursiva."""
    data = []
    for root, dirs, files in os.walk(data_path):
        for filename in files:
            if filename.endswith(".mp3"):
                file_path = os.path.join(root, filename)
                print(f"Procesando archivo {file_path}")
                # Extrae características
                mfccs = extract_mfcc(file_path)
                # Guarda las características junto con el nombre del archivo
                data.append({
                    "filename": os.path.relpath(file_path, data_path),  # Ruta relativa al directorio base
                    "mfcc": mfccs.tolist()
                })
    
    # Guardamos las características en un archivo JSON en la misma carpeta de salida
    output_path = os.path.join(data_path, "mfcc_features.json")
    with open(output_path, "w") as fp:
        json.dump(data, fp, indent=4)
    print(f"Características guardadas en {output_path}")

if __name__ == "__main__":
    # Toma la ruta de datos desde los argumentos
    if len(sys.argv) < 2:
        print("Uso: python3 preprocesamiento.py <ruta_de_la_carpeta>")
        sys.exit(1)

    data_path = sys.argv[1]
    
    if not os.path.isdir(data_path):
        print(f"Error: La ruta '{data_path}' no existe o no es un directorio.")
        sys.exit(1)

    process_all_files(data_path)