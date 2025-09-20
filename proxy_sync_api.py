import requests
import time
CONFIG_PATH = "config.py"
STATS_FILE = "stats-users.txt"
USERS_API = "https://mtp.1186899.com/get_users"  # 替换为你的获取密钥接口
ALERT_URL = "https://mtp.1186899.com/alert"      # 替换为你的报警接口
REPORT_API = "https://mtp.1186899.com/report"    # 可选：流量上报接口

warned_secrets = set()

def get_users_from_api():
    try:
        resp = requests.get(USERS_API, timeout=10)
        data = resp.json()
        # 假设返回格式为 {"users": [{"secret": "xxx", "username": "user1"}, ...]}
        users = {item["secret"]: item["username"] for item in data.get("users", [])}
        return users
    except Exception as e:
        print(f"[警告] 获取密钥接口异常: {e}")
        return None

def update_config(users):
    # 只有正常获取到密钥时才写入 config.py
    if not users:
        print("[警告] 本轮未获取到有效密钥列表，跳过 config.py 更新。")
        return
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        lines = f.readlines()
    with open(CONFIG_PATH, "w", encoding="utf-8") as f:
        for line in lines:
            if line.strip().startswith("USERS ="):
                f.write(f"USERS = {users}\n")
            else:
                f.write(line)

def report_stats():
    global warned_secrets
    with open(STATS_FILE) as f:
        for line in f:
            username, bytes_used = line.strip().split()
            # 可选：流量上报到接口
            try:
                requests.post(REPORT_API, data={"username": username, "bytes": bytes_used}, timeout=5)
            except Exception as e:
                print(f"流量上报失败: {e}")
            # 查询余额，假设接口返回 {"balance": 8, "secret": "xxx"}
            try:
                r = requests.get(f"{USERS_API}?username={username}", timeout=5)
                info = r.json()
                balance = info.get("balance", 0)
                secret = info.get("secret", "")
                if balance < 10:
                    if secret and secret not in warned_secrets:
                        try:
                            requests.get(ALERT_URL, params={"secret": secret}, timeout=5)
                            warned_secrets.add(secret)
                        except Exception as e:
                            print(f"报警接口请求失败: {e}")
                else:
                    # 余额恢复，移除报警标记
                    if secret in warned_secrets:
                        warned_secrets.remove(secret)
            except Exception as e:
                print(f"余额查询失败: {e}")

if __name__ == '__main__':
    while True:
        users = get_users_from_api()
        update_config(users)
        report_stats()
        time.sleep(60)
