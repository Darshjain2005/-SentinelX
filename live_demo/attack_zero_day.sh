#!/bin/bash
# ============================================================
#  SentinelX Demo -- Quick AI Zero-Day Attack Script
#  
#  This script skips all the normal attacks and ONLY runs the 
#  attacks designed to trigger Isolation Forest and GraphSAGE.
#
#  Usage:
#    chmod +x attack_zero_day.sh
#    sudo ./attack_zero_day.sh <ubuntu_ip>
# ============================================================

RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
CYAN='\033[0;96m'
BOLD='\033[1m'
RESET='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}[ERROR] Usage: sudo ./attack_zero_day.sh <ubuntu_ip>${RESET}"
    exit 1
fi

TARGET=$1

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run as root: sudo ./attack_zero_day.sh $TARGET${RESET}"
    exit 1
fi

echo ""
echo -e "${RED}${BOLD}============================================================${RESET}"
echo -e "${RED}${BOLD}   QUICK AI TRIGGER: ZERO-DAY ANOMALY SIMULATION${RESET}"
echo -e "${RED}${BOLD}============================================================${RESET}"
echo ""

# ──────────────────────────────────────────────────────────────
# ATTACK 1: Nmap Intense UDP Scan (Isolation Forest Trigger)
# ──────────────────────────────────────────────────────────────
echo -e "${BOLD}[ATTACK 1/2] UDP Intense Scan -- Simulating Unknown Attack${RESET}"
echo -e "${YELLOW}  Scanning top 50 UDP ports (uncommon pattern for Isolation Forest)...${RESET}"
nmap -sU -T4 --top-ports 50 $TARGET
echo -e "${GREEN}  [DONE] UDP scan complete.${RESET}"
echo ""
sleep 2

# ──────────────────────────────────────────────────────────────
# ATTACK 2: Fragmented UDP Flood (GraphSAGE Trigger)
# ──────────────────────────────────────────────────────────────
echo -e "${BOLD}[ATTACK 2/2] Fragmented UDP Flood -- Graph Anomaly Trigger${RESET}"
echo -e "${YELLOW}  Blasting $TARGET with fragmented UDP packets for GraphSAGE...${RESET}"

timeout 10 hping3 --udp --frag --flood --rand-dest $TARGET 2>/dev/null &
HPING_PID=$!
sleep 10
kill $HPING_PID 2>/dev/null
wait $HPING_PID 2>/dev/null

echo -e "${GREEN}  [DONE] Fragmented UDP flood stopped.${RESET}"
echo ""

echo -e "${CYAN}  Sequence complete! Check the SentinelX monitor on Ubuntu!${RESET}"
echo -e "${CYAN}  (Don't forget to press Ctrl+C on cicflowmeter to flush the alerts)${RESET}"
echo ""
