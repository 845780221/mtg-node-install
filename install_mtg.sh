echo "==============================="
echo "  mtg 节点一键安装脚本  "
echo "==============================="


set -e

# 固定 adtag
ADTAG="0b28e29e1ac4d675001d3a50a3ecdede"

echo "本脚本将自动安装 mtg 并配置密钥自动同步。"
echo "如遇权限问题请先执行：chmod +x install_mtg.sh"
echo "如需停止服务，可用 pkill mtg 和 pkill -f sync_secrets.sh"


# 参数优先级：命令行参数 > 交互输入 > 默认值


if [ -n "$1" ]; then
  API_URL="$1"
else
  echo "[错误] 未传入API地址，无法安装！"
  
  exit 1
fi

  NODE_ID="$1"
  MTP_PORT="$3"
  echo "[错误] 未传入 nodeId，无法安装！"
  read -rp "请输入监听端口 [默认443]: " MTP_PORT < /dev/tty
  MTP_PORT=${MTP_PORT:-443}
API_URL="https://pg-api.1186899.com/miniapi/secrets?nodeId=${NODE_ID}"
fi



  curl -s "${API_URL}&adtag=${ADTAG}" | jq -r '.secrets[].secret' > secrets.txt

if ! command -v curl >/dev/null; then
  (yum install -y curl || apt-get install -y curl)
fi
if ! command -v jq >/dev/null; then
  (yum install -y jq || apt-get install -y jq)
fi

# 2. 下载 mtg 二进制

if [ ! -f mtg ]; then
  curl -L -o mtg https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-linux-amd64
  chmod +x mtg
fi

done

# 3. 创建 secrets 同步脚本
cat > sync_secrets.sh <<EOF
#!/bin/bash
while true; do
  curl -s "${API_URL}?adtag=${ADTAG}" | jq -r '.secrets[].secret' > secrets.txt
  pkill -HUP mtg || true
  sleep 60
done
EOF
chmod +x sync_secrets.sh

# 4. 启动前先同步一次密钥并校验
echo "正在首次同步密钥..."
curl -s "${API_URL}&adtag=${ADTAG}" | jq -r '.secrets[].secret' > secrets.txt
if [ ! -s secrets.txt ]; then
  echo "[错误] 密钥文件secrets.txt未生成或为空，mtg无法启动！请检查API地址和返回内容。"
  exit 1
fi



# 6. 启动 mtg 服务
nohup ./mtg run --secrets secrets.txt --bind-to 0.0.0.0:${MTP_PORT} > mtg.log 2>&1 &
sleep 2
if ! pgrep -f "./mtg run" >/dev/null; then
  echo "[错误] mtg 启动失败，请检查 mtg.log 日志！"
  tail -n 30 mtg.log
  exit 1
fi
echo "mtg 已启动，日志见 mtg.log"

# 7. 启动密钥同步脚本
nohup ./sync_secrets.sh > sync.log 2>&1 &
echo "密钥同步脚本已启动，日志见 sync.log"

# 4. 启动 mtg 服务

nohup ./mtg run --secrets secrets.txt --bind-to 0.0.0.0:${MTP_PORT} > mtg.log 2>&1 &
echo "mtg 已启动，日志见 mtg.log"

# 5. 启动密钥同步脚本

nohup ./sync_secrets.sh > sync.log 2>&1 &
echo "密钥同步脚本已启动，日志见 sync.log"


echo "==============================="
echo "节点部署完成！"
echo "API地址: $API_URL"
echo "监听端口: $MTP_PORT"
echo "mtg版本: $MTG_VERSION"
echo "==============================="
echo "如需查看日志：tail -f mtg.log"
echo "如需停止服务：pkill mtg && pkill -f sync_secrets.sh"
