#!/usr/bin/env bash
PATH =/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
导出路径

# 字体颜色
绿色=“\0 33 [32m”
红色=“\0 33 [31m”
黄色=“\0 33 [33m”
绿色BG =“\0 33 [42;37m”
红色BG =“\0 33 [41;37m”
字体=“\0 33 [0m”
# 字体颜色

＃多变的
FRP_版本= 0 .54.0
REPO =JSCZZ/FRPs
WORK_PATH =$(目录名 $(readlink -f $0 ))
FRP_NAME =frps
FRP_PATH = / usr / local / frp
PROXY_URL =“https://mirror.ghproxy.com/”

# 检查 frps
if [ -f  “/usr/local/frp/ ${FRP_NAME} ” ] || [ -f   "/usr/local/frp/ ${FRP_NAME} .toml" ] || [ -f   "/lib/systemd/system/ ${FRP_NAME} .service" ];然后
    echo -e   " ${绿色} ============================================ == =================================== ${字体} "
    echo -e   " ${RedBG}当前已退出脚本. ${Font} "
    echo -e   " ${Green}检查到已服务器安装${Font} ${Red} ${FRP_NAME} ${Font} "    
    echo -e  " ${Green}请手动确认和删除${Font} ${Red} /usr/local/frp/ ${Font} ${Green}目录下的${Font} ${Red} ${FRP_NAME } ${字体} ${绿色}和${字体} ${红色} / ${FRP_NAME} .toml ${ 字体} ${绿色}文件以及${ 字体} ${红色} /lib/systemd/system/ ${FRP_NAME } .service ${Font} ${Green}文件，再次执行本脚本。${Font} "                  
    echo -e   " ${Green}参考命令如下: ${Font} "
    echo -e "${Red}rm -rf /usr/local/frp/${FRP_NAME}${Font}"
    echo -e "${Red}rm -rf /usr/local/frp/${FRP_NAME}.toml${Font}"
    echo -e "${Red}rm -rf /lib/systemd/system/${FRP_NAME}.service${Font}"
    echo -e "${Green}=========================================================================${Font}"
    exit 2
fi

尽管！测试-z  " $(ps -A | grep -w ${FRP_NAME} ) " ; 做
    FRPSPID=$(ps -A | grep -w ${FRP_NAME} | awk 'NR==1 {print $1}')
    kill -9 $FRPSPID
done

# check pkg
if type apt-get >/dev/null 2>&1 ; then
    if ! type wget >/dev/null 2>&1 ; then
        apt-get install wget -y
    fi
    if ! type curl >/dev/null 2>&1 ; then
        apt-get install curl -y
    fi
fi

if type yum >/dev/null 2>&1 ; then
    if ! type wget >/dev/null 2>&1 ; then
        yum install wget -y
    fi
    if ! type curl >/dev/null 2>&1 ; then
        yum install curl -y
    fi
fi

# check network
GOOGLE_HTTP_CODE=$(curl -o /dev/null --connect-timeout 5 --max-time 8 -s --head -w "%{http_code}" "https://www.google.com")
PROXY_HTTP_CODE=$(curl -o /dev/null --connect-timeout 5 --max-time 8 -s --head -w "%{http_code}" "${PROXY_URL}")

# check arch
if [ $(uname -m) = "x86_64" ]; then
    PLATFORM=amd64
fi

if [ $(uname -m) = "aarch64" ]; then
    PLATFORM=arm64
fi

FILE_NAME=frp_${FRP_VERSION}_linux_${PLATFORM}

# download
if [ $GOOGLE_HTTP_CODE == "200" ]; then
    wget -P ${WORK_PATH} https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}.tar.gz -O ${FILE_NAME}.tar.gz
    wget -P ${WORK_PATH} https://raw.githubusercontent.com/${REPO}/master/${FRP_NAME}.toml -O ${FRP_NAME}.toml
else
    if [ $PROXY_HTTP_CODE == "200" ]; then
        wget -P ${WORK_PATH} ${PROXY_URL}https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}.tar.gz -O ${FILE_NAME}.tar.gz
        wget -P ${WORK_PATH} ${PROXY_URL}https://raw.githubusercontent.com/${REPO}/master/${FRP_NAME}.toml -O ${FRP_NAME}.toml
    else
        echo -e "${Red}检测 GitHub Proxy 代理失效 开始使用官方地址下载${Font}"
        wget -P ${WORK_PATH} https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}.tar.gz -O ${FILE_NAME}.tar.gz
        wget -P ${WORK_PATH} https://raw.githubusercontent.com/${REPO}/master/${FRP_NAME}.toml -O ${FRP_NAME}.toml
    fi
fi
tar -zxvf ${FILE_NAME}.tar.gz
mkdir -p ${FRP_PATH}
mv ${FILE_NAME}/${FRP_NAME} ${FRP_PATH}
mv ${FRP_NAME}.toml ${FRP_PATH}

# 配置 frps.service
cat >/lib/systemd/system/frps.service <<'EOF'
[Unit]
Description=Frp Server Service
After=network.target syslog.target
Wants=network.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.toml

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
sudo systemctl start ${FRP_NAME}
sudo systemctl enable ${FRP_NAME}

# clean
rm -rf ${WORK_PATH}/${FILE_NAME}.tar.gz ${WORK_PATH}/${FILE_NAME} ${FRP_NAME}_linux_install.sh

echo -e "${Green}====================================================================${Font}"
echo -e "${Green}安装成功,请先修改 ${FRP_NAME}.toml 文件,确保格式及配置正确无误!${Font}"
echo -e "${Red}vi /usr/local/frp/${FRP_NAME}.toml${Font}"
echo -e "${Green}修改完毕后执行以下命令重启服务:${Font}"
echo -e "${Red}sudo systemctl restart ${FRP_NAME}${Font}"
echo -e "${Green}====================================================================${Font}"
