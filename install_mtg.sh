# curl -s https://raw.githubusercontent.com/845780221/mtg-node-install/main/install_mtg.sh | bash
# https://pg-api.1186899.com/miniapi/secrets

echo "==============================="
echo "  mtg 节点一键安装脚本  "
echo "==============================="


set -e

# 固定 adtag
ADTAG="0b28e29e1ac4d675001d3a50a3ecdede"

echo "本脚本将自动安装 mtg 并配置密钥自动同步。"
echo "如遇权限问题请先执行：chmod +x install_mtg.sh"
echo "如需停止服务，可用 pkill mtg 和 pkill -f sync_secrets.sh"

NODE_ID=${1:-"node-001"}
API_URL=${2:-"https://your-master/api/secrets"}
MTP_PORT=${3:-443}

read -rp "请输入节点名称（nodeId）: " NODE_ID
read -rp "请输入主控端接口地址（如 https://your-master/api/secrets）: " API_URL
read -rp "请输入监听端口 [默认443]: " MTP_PORT
MTP_PORT=${MTP_PORT:-443}
read -rp "请输入mtg版本 [默认v1.0.0]: " MTG_VERSION
MTG_VERSION=${MTG_VERSION:-v1.0.0}

# 1. 安装依赖

if ! command -v curl >/dev/null; then
  (yum install -y curl || apt-get install -y curl)
fi
if ! command -v jq >/dev/null; then
  (yum install -y jq || apt-get install -y jq)
fi

# 2. 下载 mtg 二进制

if [ ! -f mtg ]; then
  curl -L -o mtg https://github.com/9seconds/mtg/releases/download/${MTG_VERSION}/mtg-linux-amd64
  chmod +x mtg
fi

# 3. 创建 secrets 同步脚本
done
cat > sync_secrets.sh <<EOF
#!/bin/bash
while true; do
  curl -s "${API_URL}?nodeId=${NODE_ID}&adtag=${ADTAG}" | jq -r '.secrets[].secret' > secrets.txt
  pkill -HUP mtg || true
  sleep 60
done
EOF
chmod +x sync_secrets.sh

# 4. 启动 mtg 服务

nohup ./mtg run --secrets secrets.txt --bind-to 0.0.0.0:${MTP_PORT} > mtg.log 2>&1 &
echo "mtg 已启动，日志见 mtg.log"

# 5. 启动密钥同步脚本

nohup ./sync_secrets.sh > sync.log 2>&1 &
echo "密钥同步脚本已启动，日志见 sync.log"


echo "==============================="
echo "节点部署完成！"
echo "节点ID: $NODE_ID"
echo "API地址: $API_URL"
echo "监听端口: $MTP_PORT"
echo "mtg版本: $MTG_VERSION"
echo "==============================="
echo "如需查看日志：tail -f mtg.log"
echo "如需停止服务：pkill mtg && pkill -f sync_secrets.sh"
