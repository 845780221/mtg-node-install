#!/bin/bash
# Ubuntu 一键安装 mtprotoproxy + 自动同步脚本
set -e

# 1. 安装依赖
sudo apt-get update
sudo apt-get install -y python3 python3-pip git

# 2. 克隆仓库（如已存在则跳过）
if [ ! -d mtg-node-install ]; then
  git clone https://github.com/845780221/mtg-node-install.git
fi
cd mtg-node-install

# 3. 生成 requirements.txt（如不存在）
if [ ! -f requirements.txt ]; then
  echo -e "aiohttp\npyaes" > requirements.txt
fi

# 4. 安装 Python 依赖
pip3 install -r requirements.txt
pip3 install requests

# 5. 启动 mtprotoproxy
nohup python3 mtprotoproxy.py > mtproto.log 2>&1 &

# 6. 启动自动同步脚本
nohup python3 proxy_sync_api.py > sync.log 2>&1 &

echo "==============================="
echo "全部服务已启动，日志见 mtproto.log 和 sync.log"
echo "如需停止服务：pkill -f mtprotoproxy.py && pkill -f proxy_sync_api.py"
echo "如需查看日志：tail -f mtproto.log"
