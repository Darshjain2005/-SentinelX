"""
Detection Engines Evaluator

Evaluates both the Rule Engine and the Isolation Forest against a sample 
of the CIC-IDS2017 dataset to calculate Precision, Recall, and F1.
"""

import os
import pandas as pd
from sklearn.metrics import classification_report, accuracy_score
import time

from rule_engine import RuleEngine
from isolation_forest import AnomalyDetector

DATASET_PATH = os.path.join(os.path.dirname(__file__), "..", "dataset", "combinenew.csv")
RULES_DIR = os.path.join(os.path.dirname(__file__), "rules")

def load_data(sample_size: int = 50000):
    print(f"Loading {sample_size} random rows for evaluation...")
    # Load a stratified sample
    df = pd.read_csv(DATASET_PATH, low_memory=False)
    df.columns = df.columns.str.strip()
    df["Label"] = df["Label"].astype(str).str.strip()
    
    # Create Binary Label
    df["BinaryLabel"] = (df["Label"] != "BENIGN").astype(int)
    
    # Drop NaNs
    df.replace([float('inf'), float('-inf')], pd.NA, inplace=True)
    df.dropna(inplace=True)
    
    # Stratified sample
    if len(df) > sample_size:
        df_sample = df.groupby("BinaryLabel", group_keys=False).apply(
            lambda x: x.sample(n=max(1, int(sample_size * len(x) / len(df))), random_state=42),
            include_groups=True
        )
    else:
        df_sample = df
        
    return df_sample.reset_index(drop=True)

def evaluate_rule_engine(df: pd.DataFrame):
    print("\n--- Evaluating Rule Engine ---")
    engine = RuleEngine(RULES_DIR)
    
    start_time = time.time()
    rule_results = engine.scan_dataframe(df)
    eval_time = time.time() - start_time
    
    # A rule matches if the list is not empty
    y_pred = rule_results.apply(lambda rules: 1 if len(rules) > 0 else 0)
    y_true = df["BinaryLabel"]
    
    print(f"Rule Engine evaluated in {eval_time:.2f} seconds.")
    print("Rule Engine Performance (Detecting Known Threats):")
    print("-" * 50)
    print(classification_report(y_true, y_pred, target_names=["BENIGN", "Attack"]))
    return y_pred, rule_results

def evaluate_isolation_forest(df: pd.DataFrame):
    print("\n--- Evaluating Isolation Forest ---")
    
    # Split into train/test
    # Isolation Forest is trained on mostly BENIGN traffic
    df_train = df.sample(frac=0.6, random_state=42)
    df_test = df.drop(df_train.index)
    
    detector = AnomalyDetector(contamination=0.10) # Assume 10% anomalies
    detector.train(df_train)
    
    start_time = time.time()
    anomaly_results = detector.predict(df_test)
    eval_time = time.time() - start_time
    
    y_pred = anomaly_results.astype(int)
    y_true = df_test["BinaryLabel"]
    
    print(f"Isolation Forest evaluated in {eval_time:.2f} seconds.")
    print("Isolation Forest Performance (Detecting Anomalies):")
    print("-" * 50)
    print(classification_report(y_true, y_pred, target_names=["BENIGN", "Anomaly (Attack)"]))
    return y_pred

if __name__ == "__main__":
    df = load_data()
    evaluate_rule_engine(df)
    evaluate_isolation_forest(df)
