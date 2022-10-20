unzip /iswell/iswell.zip -d /iswell
unzip /building/building.zip  -d /building
rm -rf /iswell/iswell.zip
rm -rf /building/building.zip
chmod +x /iswell/sing-box
mkdir /etc/sing-box
cat << EOF > /etc/sing-box/config.json
{
    "dns": {
        "servers": [
            {
                "tag": "google-tls",
                "address": "local",
                "address_strategy": "prefer_ipv4",
                "strategy": "ipv4_only",
                "detour": "direct"
            },
            {
                "tag": "google-udp",
                "address": "8.8.8.8",
                "address_strategy": "prefer_ipv4",
                "strategy": "prefer_ipv4",
                "detour": "direct"
            }
        ],
        "strategy": "prefer_ipv4",
        "disable_cache": false,
        "disable_expire": false
    },
    "inbounds": [
        {
            "type": "vmess",
            "tag": "vmess-in",
            "listen": "127.0.0.1",
            "listen_port": 23323,
            "tcp_fast_open": true,
            "sniff": true,
            "sniff_override_destination": false,
            "domain_strategy": "prefer_ipv4",
            "proxy_protocol": false,
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
        },
        {
            "type": "block",
            "tag": "block"
        },
        {
            "type": "dns",
            "tag": "dns-out"
        }
    ],
    "route": {
        "rules": [
            {
                "protocol": "dns",
                "outbound": "dns-out"
            },
            {
                "inbound": [
                    "vmess-in"
                ],
                "geosite": [
                    "cn",
                    "category-ads-all"
                ],
                "geoip": "cn",
                "outbound": "block"
            }
        ],
        "geoip": {
            "path": "geoip.db",
            "download_url": "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db",
            "download_detour": "direct"
        },
        "geosite": {
            "path": "geosite.db",
            "download_url": "https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db",
            "download_detour": "direct"
        },
        "final": "direct",
        "auto_detect_interface": true
    }
}
EOF
chmod +x /etc/sing-box/config.json
echo /building/index.html
cat /building/index.html
rm -rf /etc/nginx/sites-enabled/default
# Let's get start
/iswell/sing-box run -c /etc/sing-box/config.json &
echo /building/index.html
cat /building/index.html
rm -rf /etc/nginx/sites-enabled/default
/bin/bash -c "envsubst '\$PORT,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
