import os
import numpy as np
import librosa
import librosa.display
import matplotlib.pyplot as plt
import json

# Directorio de archivos mp3
DATA_PATH = "data/"
FEATURES_PATH = "features/"
SAMPLE_RATE = 22050  # Frecuencia de muestreo común en librosa

# Crea el directorio de características si no existe
os.makedirs(FEATURES_PATH, exist_ok=True)

# Función para extraer MFCCs de un archivo .mp3
def extract_mfcc(file_path, n_mfcc=13):
    # Carga el archivo de audio
    y, sr = librosa.load(file_path, sr=SAMPLE_RATE)
    # Extrae MFCCs
    mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=n_mfcc)
    # Toma la media de los MFCCs por segmento temporal
    mfcc_mean = np.mean(mfcc.T, axis=0)
    return mfcc_mean

# Procesa todos los archivos .mp3 en el directorio DATA_PATH
def process_all_files():
    data = []
    for filename in os.listdir(DATA_PATH):
        if filename.endswith(".mp3"):
            file_path = os.path.join(DATA_PATH, filename)
            print(f"Procesando archivo {filename}")
            # Extrae características
            mfccs = extract_mfcc(file_path)
            # Guarda las características junto con el nombre del archivo
            data.append({
                "filename": filename,
                "mfcc": mfccs.tolist()  # Guardamos como lista para serializar en JSON
            })
    
    # Guardamos las características extraídas en un archivo JSON
    with open(os.path.join(FEATURES_PATH, "mfcc_features.json"), "w") as fp:
        json.dump(data, fp, indent=4)

if __name__ == "__main__":
    process_all_files()
