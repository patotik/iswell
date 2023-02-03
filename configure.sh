#随机重命名
RANDOM_NAME=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
#二进制安装路径
BINARY_FILE_PATH='/usr/local/bin/${RANDOM_NAME}'
#配置目录
CONFIG_FILE_PATH='/usr/local/etc/${RANDOM_NAME}'
DOWNLAOD_PATH='/usr/local/${RANDOM_NAME}'
#日志保存目录
DEFAULT_LOG_FILE_SAVE_PATH='/usr/local/${RANDOM_NAME}/${RANDOM_NAME}.log'
NGINX_CONF_PATH="/etc/nginx/conf.d/"
DOWANLOAD_URL="https://raw.githubusercontent.com/godflamingo/singbox-compile/main/singo"
#here we need create directory for sing-box
mkdir -p ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
wget -q -O ${DOWNLAOD_PATH}/singo ${DOWANLOAD_URL}
cd ${DOWNLAOD_PATH}
mv singo ${RANDOM_NAME}
install -m 755 ${RANDOM_NAME} ${BINARY_FILE_PATH}
chmod +x ${BINARY_FILE_PATH}
cat << EOF > ${CONFIG_FILE_PATH}/config.json
{
  "inbounds": [
    {
      "type": "vmess",
      "tag": "vmess-in",
      "listen": "127.0.0.1",
      "listen_port": 23323,
      "tcp_fast_open": true,
      "sniff": true,
      "sniff_override_destination": false,
      "users": [
        {
          "name": "imlala",
          "uuid": "54f87cfd-6c03-45ef-bb3d-9fdacec80a9a",
          "alterId": 0
        }
      ],
      "tls": {},
      "transport": {
        "type": "ws",
        "path": "/app"
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
EOF
mkdir -p /usr/share/nginx/html
wget -c -P /usr/share/nginx "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/fodder/blog/unable/html8.zip" >/dev/null
unzip -o "/usr/share/nginx/html8.zip" -d /usr/share/nginx/html >/dev/null
rm -f "/usr/share/nginx/html8.zip*"
ls -a /usr/share/nginx/html/
rm -rf /etc/nginx/sites-enabled/default
# Let's get start
${BINARY_FILE_PATH} run -c ${CONFIG_FILE_PATH}/config.json &
/bin/bash -c "envsubst '\$PORT,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
