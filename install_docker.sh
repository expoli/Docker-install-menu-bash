#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: docker install
#	Version: 1.0.0
#	Author: zzutcy
#	Blog: http://zzucty.top
#   created 2019.02.21
#   email zzucty@gmail.com,zzutcy@qq.com
#=================================================

sh_ver="1.0.0"
server_file="/usr/bin"
docker_daemon_json="/etc/docker/daemon.json"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}

Installation_dependency(){
    if [[ ${release} == "centos" ]]; then
        sudo yum -y update 
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2 
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
    else
        sudo apt-get update -y
        sudo apt-get remove -y docker docker-engine docker.io containerd runc
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update -y
        sudo apt-get install docker-ce docker-ce-cli containerd.io
    fi
}

Set_Docker_Fast_Mirrors(){
    mkdir -p /etc/docker
    cat > ${docker_daemon_json}<<-EOF
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF
    Restart_Docker
}

Install_Docker(){
	[[ -e "${server_file}/docker" ]] && echo -e "${Error} 检测到 Docker 已安装 ! 请卸载现有版本再进行安装!" && exit 1
	echo -e "${Info} 开始安装/配置 依赖..."
	Installation_dependency
	echo -e "${Info} 所有步骤 安装完毕."
    docker info
	echo -e "${Info} 开启守护进程,设置为开机启动并开始启动..."
	Start_Docker
}
# 启动 Docker
Start_Docker(){
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo systemctl status docker
}
# 
Stop_Docker(){
    sudo systemctl stop docker
}
# 
Restart_Docker(){
    sudo systemctl daemon-reload
    sudo systemctl restart docker
}
# 卸载Docker
Uninstall_Docker(){
    if [[ ${release} == "centos" ]]; then
        sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
    else

        sudo apt-get remove docker docker-engine docker.io containerd runc -y
    fi
}
# 更新Docker
Update_Docker(){
    if [[ ${release} == "centos" ]]; then
        sudo yum update -y docker 
    else

        sudo apt-get update docker -y
    fi
}
# 安装docker-compose
Install_Docker_compose(){
    sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker-compose --version
}
# 
View_Docker_Status(){
    check_pid_server
    sudo systemctl status docker
}
# 
check_pid_server(){
	PID=`ps -ef| grep "docker"| grep -v grep| grep -v ".sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}'`
}

Update_Shell(){
	# sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/status.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	# [[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 Github !" && exit 0
	# wget -N --no-check-certificate "https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/status.sh" && chmod +x status.sh
	echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
}

menu_server(){
echo && echo -e "  Docker 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- zzutcy | zzutcy/shell --
  
 ${Green_font_prefix} 0.${Font_color_suffix} 升级脚本
 ————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 安装 Docker
 ${Green_font_prefix} 2.${Font_color_suffix} 更新 Docker
 ${Green_font_prefix} 3.${Font_color_suffix} 卸载 Docker
————————————
 ${Green_font_prefix} 4.${Font_color_suffix} 启动 Docker
 ${Green_font_prefix} 5.${Font_color_suffix} 停止 Docker
 ${Green_font_prefix} 6.${Font_color_suffix} 重启 Docker
 ————————————
 ${Green_font_prefix} 7.${Font_color_suffix} 设置加速镜像源
 ${Green_font_prefix} 8.${Font_color_suffix} 安装 docker-compose
 ${Green_font_prefix} 9.${Font_color_suffix} 查看 docker 运行状态" && echo
if [[ -e "${server_file}/docker" ]]; then
	check_pid_server
	if [[ ! -z "${PID}" ]]; then
		echo -e " 当前状态: Docker ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
	else
		echo -e " 当前状态: Docker ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
	fi
else
	echo -e " 当前状态: Docker ${Red_font_prefix}未安装${Font_color_suffix}"
fi
echo
read -e -p " 请输入数字 [0-10]:" num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	Install_Docker
	;;
	2)
	Update_Docker
	;;
	3)
	Uninstall_Docker
	;;
	4)
	Start_Docker
	;;
	5)
	Stop_Docker
	;;
	6)
	Restart_Docker
	;;
	7)
	Set_Docker_Fast_Mirrors
	;;
	8)
	Install_Docker_compose
	;;
	9)
	View_Docker_Status
	;;
	*)
	echo "请输入正确数字 [0-10]"
	;;
esac
}
check_sys
menu_server
