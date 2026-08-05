"""
Detection Engine Main Pipeline

Entry point for running both the Rule Engine and Isolation Forest.
"""

import sys
import io

# Force UTF-8 output on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

from evaluate_engines import load_data, evaluate_rule_engine, evaluate_isolation_forest

def main():
    print("=" * 60)
    print("   SENTINELX -- Detection Engine Pipeline")
    print("=" * 60 + "\n")
    
    print("[*] Initializing test dataset...")
    # Using 30k rows for faster evaluation
    df = load_data(sample_size=30000)
    print(f"    Dataset loaded: {len(df)} rows.\n")
    
    print("[*] Running Module 1: Sigma-Inspired Rule Engine")
    rule_preds, triggered = evaluate_rule_engine(df)
    
    print("\n[*] Running Module 2: Isolation Forest Anomaly Detection")
    evaluate_isolation_forest(df)
    
    print("\n" + "=" * 60)
    print("   [OK] Detection Engine Pipeline Complete")
    print("=" * 60 + "\n")

if __name__ == "__main__":
    main()
