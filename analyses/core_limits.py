import pandas as pd
import ruptures as rpt
from pathlib import Path

# Define the folder path
folder = Path("output/inference/")

# Iterate over all CSV files in the folder
for file_path in folder.glob("*.csv"):
    # Read the file
    df = pd.read_csv(file_path)
    # Check if 'MWSS' column exists to prevent crashes on different files
    if "MWSS" in df.columns:
        signal = df["MWSS"].to_numpy()
        
        # Apply PELT algorithm
        modelo = rpt.Pelt(model="l1", jump=1).fit(signal)
        pen=0.5
        if file_path.name == "moments_portal_rodents.csv":
            pen = 0.1 #this is to get more than 1 rupture point
        puntos_de_cambio = modelo.predict(pen=pen)
        
        print(f"{file_path.name}: {puntos_de_cambio}")
    else:
        print(f"{file_path.name}: Skipped (No 'MRSS' column found)")