# SentinelX: Advanced AI-Powered SOC Platform

SentinelX is a next-generation Security Operations Center (SOC) platform that combines traditional detection engineering with advanced Machine Learning to identify zero-day threats in real-time.

This project was built as a Final Year Project based on a comprehensive SOC blueprint, integrating multiple layers of defense to protect network infrastructure.

## 🚀 Core Features

1. **Zero-Day Detection (GraphSAGE)**
   - Utilizes a powerful Graph Neural Network (GraphSAGE via PyTorch Geometric).
   - Models network flows as a k-Nearest Neighbors graph to identify structural anomalies and unseen attack vectors.
   - **Performance:** Achieved **98.25% Recall** and **96.80% Accuracy** on the CIC-IDS2017 dataset.

2. **Rule Engine (Sigma-Inspired)**
   - A deterministic, high-speed matching engine that uses YAML-based rules (inspired by Sigma) to instantly catch known threats like DoS, Brute Force, and Port Scans.
   - Extensible architecture allowing analysts to easily write and deploy new signatures.

3. **Anomaly Detection (Isolation Forest)**
   - Unsupervised machine learning (`scikit-learn`) deployed alongside the rule engine.
   - Learns the statistical baseline of benign traffic and isolates deviations without requiring labeled attack data.

4. **Live Monitor & Demo Mode**
   - Built-in real-time traffic monitor (`live_demo/live_monitor.py`) designed to interface with live network capture tools like `cicflowmeter`.
   - Simulates a live SOC dashboard directly in the terminal, aggregating alerts from all three engines.

## 📁 Repository Structure

- `zero_day_module/`: GraphSAGE model architecture, training loops, and data preprocessing.
- `detection_engine/`: The Rule Engine, Isolation Forest model, and YAML threat signatures.
- `live_demo/`: Scripts for conducting a live Attack/Defense demonstration between Kali Linux and Ubuntu VMs.
- `documentation/`: Project blueprints and reference materials.

## 🛠️ Technology Stack

- **Machine Learning**: PyTorch, PyTorch Geometric, Scikit-Learn
- **Data Processing**: Pandas, NumPy
- **Threat Engineering**: Custom YAML parsing engine
- **Network Capture**: CICFlowMeter (Live Demo integration)

## 🏁 Getting Started

### Prerequisites
Make sure you have Python 3.9+ installed.
```bash
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install torch_geometric scikit-learn pandas numpy pyyaml seaborn
```

### Running the Engines
Test the Zero-Day GraphSAGE model:
```bash
python zero_day_module/main.py
```

Test the Detection Engine:
```bash
python detection_engine/main.py
```

Run the Live Simulator (simulates live traffic from the dataset):
```bash
python live_demo/live_monitor.py --simulate --file dataset/combinenew.csv
```

## 🔐 Future Roadmap
- Backend API implementation using **FastAPI** to serve model inferences.
- Frontend SOC Dashboard using **React** and **Tailwind CSS**.
- **AI SOC Assistant (RAG)** to provide conversational incidence investigation.

---
*Built as a Final Year Academic Project.*
