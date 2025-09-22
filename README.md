# Async MTProto Proxy #

Fast and simple to setup MTProto proxy written in Python.

## Starting Up ##
    
1. `git clone -b stable https://github.com/alexbers/mtprotoproxy.git; cd mtprotoproxy`
2. *(optional, recommended)* edit *config.py*, set **PORT**, **USERS** and **AD_TAG**
3. `docker-compose up -d` (or just `python3 mtprotoproxy.py` if you don't like Docker)
4. *(optional, get a link to share the proxy)* `docker-compose logs`

![Demo](https://alexbers.com/mtprotoproxy/install_demo_v2.gif)

## Channel Advertising ##

To advertise a channel get a tag from **@MTProxybot** and put it to *config.py*.

## Performance ##

The proxy performance should be enough to comfortably serve about 4 000 simultaneous users on
the VDS instance with 1 CPU core and 1024MB RAM.

## More Instructions ##

- [Running without Docker](https://github.com/alexbers/mtprotoproxy/wiki/Running-Without-Docker)
- [Optimization and fine tuning](https://github.com/alexbers/mtprotoproxy/wiki/Optimization-and-Fine-Tuning)

## Advanced Usage ##

The proxy can be launched:
- with a custom config: `python3 mtprotoproxy.py [configfile]`
- several times, clients will be automaticaly balanced between instances
- with uvloop module to get an extra speed boost
- with runtime statistics exported to [Prometheus](https://prometheus.io/)



## 
# 1. 安装 git、python3、pip3
sudo apt-get update || sudo yum makecache
sudo apt-get install -y python3 python3-pip git || sudo yum install -y python3 python3-pip git

# 2. 克隆你的仓库（假设你已将 mtprotoproxy、proxy_sync_api.py 等都放在自己的仓库）
git clone https://github.com/845780221/mtg-node-install.git
cd 你的仓库

# 3. 安装 Python 依赖
pip3 install -r requirements.txt
pip3 install requests

# 4. 启动 mtprotoproxy
nohup python3 mtprotoproxy.py > mtproto.log 2>&1 &

# 5. 启动自动同步脚本
nohup python3 proxy_sync_api.py > sync.log 2>&1 &

echo "全部服务已启动，日志见 mtproto.log 和 sync.log"