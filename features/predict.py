import json
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report

# Cargar los datos de los tres archivos JSON
def load_data(file_path, label):
    with open(file_path, "r") as f:
        data = json.load(f)
    return [(entry["mfcc"], label) for entry in data]

# Etiquetas: 0 = base, 1 = melodía, 2 = cantada
data = load_data("bases.json", 0) + load_data("melodias.json", 1) + load_data("cantadas.json", 2)

# Separar características y etiquetas
X = np.array([entry[0] for entry in data])
y = np.array([entry[1] for entry in data])

# Dividir los datos en entrenamiento y prueba
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Entrenar el modelo
clf = RandomForestClassifier(n_estimators=100, random_state=42)
clf.fit(X_train, y_train)

# Evaluar el modelo
y_pred = clf.predict(X_test)
print(classification_report(y_test, y_pred, target_names=["Base", "Melodía", "Cantada"]))
