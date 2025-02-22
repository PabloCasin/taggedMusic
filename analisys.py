import os
import sys
import numpy as np
import librosa
import json

# Configuración de parámetros
SAMPLE_RATE = 22050  # Frecuencia de muestreo común en librosa
N_MFCC = 13  # Número de coeficientes MFCC

def extract_features(file_path, n_mfcc=N_MFCC):
    """Extrae los MFCCs promedio y otras características de un archivo de audio."""
    y, sr = librosa.load(file_path, sr=SAMPLE_RATE)
    
    # MFCCs
    mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=n_mfcc)
    mfcc_mean = np.mean(mfcc.T, axis=0)
    
    # Características adicionales
    rms = librosa.feature.rms(y=y).mean()
    spectral_centroid = librosa.feature.spectral_centroid(y=y, sr=sr).mean()
    spectral_bandwidth = librosa.feature.spectral_bandwidth(y=y, sr=sr).mean()
    zcr = librosa.feature.zero_crossing_rate(y=y).mean()
    
    return {
        "mfcc": mfcc_mean.tolist(),
        "rms": rms,
        "spectral_centroid": spectral_centroid,
        "spectral_bandwidth": spectral_bandwidth,
        "zcr": zcr
    }

def process_all_files(data_path):
    """Procesa todos los archivos .mp3 en el directorio especificado de forma recursiva."""
    data = []
    for root, dirs, files in os.walk(data_path):
        for filename in files:
            if filename.endswith(".mp3"):
                file_path = os.path.join(root, filename)
                print(f"Procesando archivo {file_path}")
                
                # Extrae características
                features = extract_features(file_path)
                
                # Guarda las características junto con el nombre del archivo
                data.append({
                    "filename": os.path.relpath(file_path, data_path),  # Ruta relativa al directorio base
                    **features
                })
    
    # Guardamos las características en un archivo JSON en la misma carpeta de salida
    output_path = os.path.join(data_path, "audio_features.json")
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
