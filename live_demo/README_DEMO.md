# SentinelX Live Zero-Day Demo -- Step-by-Step Guide

This guide walks you through demonstrating SentinelX's zero-day detection
using two VMs: **Kali Linux** (attacker) and **Ubuntu** (defender).

---

## PREREQUISITES

### On Your Windows Machine (Where You Developed)
You need to copy these folders to the Ubuntu VM:
```
zero_day_module/         (entire folder)
detection_engine/        (entire folder)
live_demo/               (entire folder)
dataset/                 (only needed if you want to run the simulator on Ubuntu)
```

### On the Ubuntu VM
Install the following Python packages:

```bash
sudo apt update
sudo apt install python3 python3-pip libpcap-dev -y

pip3 install torch --index-url https://download.pytorch.org/whl/cpu
pip3 install torch_geometric
pip3 install scikit-learn numpy pandas pyyaml seaborn
pip3 install cicflowmeter
```

### Network Setup
Both VMs must be on the **same network**. Recommended:
- Set both VMs to **"Host-Only Adapter"** or **"Internal Network"** in VirtualBox/VMware.
- Note down the Ubuntu VM's IP address:
  ```bash
  ip addr show
  ```
  Example: `192.168.56.101`

---

## STEP-BY-STEP DEMO

### STEP 1: Transfer Files to Ubuntu VM

**Option A: Using SCP (from Windows PowerShell)**
```powershell
# Replace <ubuntu_ip> and <ubuntu_user> with your values
scp -r "D:\projects\final year project\zero_day_module" <ubuntu_user>@<ubuntu_ip>:~/sentinelx/
scp -r "D:\projects\final year project\detection_engine" <ubuntu_user>@<ubuntu_ip>:~/sentinelx/
scp -r "D:\projects\final year project\live_demo" <ubuntu_user>@<ubuntu_ip>:~/sentinelx/
```

**Option B: Using a USB drive or Shared Folder**
Copy `zero_day_module/`, `detection_engine/`, and `live_demo/` into `~/sentinelx/` on Ubuntu.

Your Ubuntu folder structure should look like:
```
~/sentinelx/
├── zero_day_module/
│   ├── config.py
│   ├── model.py
│   ├── graph_construction.py
│   ├── results/
│   │   └── best_graphsage_model.pth    <-- IMPORTANT: the trained model weights
│   └── ...
├── detection_engine/
│   ├── rule_engine.py
│   ├── isolation_forest.py
│   └── rules/
│       ├── brute_force.yaml
│       ├── dos_attack.yaml
│       └── port_scan.yaml
├── live_demo/
│   └── live_monitor.py
└── dataset/                             <-- Optional, only for simulator mode
    └── combinenew.csv
```

---

### STEP 2: Start CICFlowMeter on Ubuntu (Terminal 1)

Open a terminal on Ubuntu and run:
```bash
# Find your network interface name
ip link show
# Usually it's eth0, ens33, or enp0s3

# Start capturing traffic and saving to CSV
sudo cicflowmeter -i eth0 -c ~/sentinelx/live_traffic.csv
```

This will start sniffing all network packets on `eth0` and converting them
into the 78-feature CSV format that our ML models understand.

---

### STEP 3: Start SentinelX Live Monitor on Ubuntu (Terminal 2)

Open a SECOND terminal on Ubuntu and run:
```bash
cd ~/sentinelx
python3 live_demo/live_monitor.py --file ~/sentinelx/live_traffic.csv
```

You should see:
```
============================================================
   SENTINELX -- LIVE ZERO-DAY DETECTION MONITOR
============================================================

[*] Loading SentinelX Detection Engines...
    - Rule Engine Loaded (3 rules)
    - Initializing Isolation Forest...
    - GraphSAGE Loaded successfully.

[*] SentinelX is Active. Monitoring live_traffic.csv ...
------------------------------------------------------------
```

The monitor is now waiting for traffic to appear in the CSV file.

---

### STEP 4: Launch Attacks from Kali Linux

Open a terminal on Kali and run any of these attacks targeting the Ubuntu IP:

**Attack 1: Nmap Port Scan**
```bash
nmap -sS -T4 -p 1-1000 <ubuntu_ip>
```

**Attack 2: Aggressive Nmap Scan (triggers more alerts)**
```bash
nmap -A -T5 <ubuntu_ip>
```

**Attack 3: SSH Brute Force (using Hydra)**
```bash
# First make sure SSH is running on Ubuntu: sudo systemctl start ssh
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://<ubuntu_ip>
```

**Attack 4: DoS with hping3**
```bash
sudo hping3 -S --flood -V -p 80 <ubuntu_ip>
```

**Attack 5: Metasploit Exploit (advanced)**
```bash
msfconsole
use auxiliary/scanner/portscan/tcp
set RHOSTS <ubuntu_ip>
run
```

---

### STEP 5: Watch Alerts on Ubuntu Terminal 2

As soon as Kali starts attacking, you should see alerts like:

```
[!] ALERT TRIGGERED
 > Flow #   : 15
 > Engine   : Sigma Rule Engine
 > Details  : Signature match: Port Scanning Activity
 > Severity : HIGH
------------------------------------------------------------

[!] ALERT TRIGGERED
 > Flow #   : 23
 > Engine   : GraphSAGE
 > Details  : Zero-Day / Unknown Attack structure detected. (Confidence: 98.5%)
 > Severity : CRITICAL
------------------------------------------------------------
```

### STEP 6: Stop the Demo

Press `Ctrl+C` on both terminals to stop the monitor and cicflowmeter.
The monitor will print a final summary of all alerts detected.

---

## TROUBLESHOOTING

| Problem | Solution |
|---------|----------|
| `cicflowmeter` not found | `pip3 install cicflowmeter` and try with `sudo` |
| No alerts appearing | Make sure both VMs are on the same network. Check `ping <ubuntu_ip>` from Kali. |
| `ModuleNotFoundError` | Make sure all pip packages are installed on Ubuntu. Run the pip install commands from Prerequisites. |
| CSV file empty | Try a different interface name (`ens33`, `enp0s3` instead of `eth0`). Use `ip link show` to check. |
| GraphSAGE model not loading | Make sure you copied `zero_day_module/results/best_graphsage_model.pth` to Ubuntu. |

---

## RUNNING THE SIMULATOR (No VMs needed)

If you just want to show the demo on a single machine without VMs:
```bash
cd ~/sentinelx
python3 live_demo/live_monitor.py --simulate --file dataset/combinenew.csv
```
This feeds 200 sample flows (mix of benign + attack) through the system automatically.
