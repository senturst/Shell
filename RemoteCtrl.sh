#!/bin/bash  
TYPE=$1  
#变量定义  
#ip_array=("192.168.0.200")  
  
#本地通过ssh执行远程服务器的脚本  
#停服更新
if [[ $TYPE == 'full' ]];then
while read ip
do  {
    echo -e "\033[32;49;1m [开始全量更新] \033[39;49;0m"
    ssh $ip 'rm -rf /data/update/*';
    echo -e "\033[32;49;1m [删除旧文件完成] \033[39;49;0m"
    rsync -avrzI --exclude=xysvr.config server/ root@$ip:/data/update;
    echo -e "\033[32;49;1m [文件上传完成] \033[39;49;0m"
    ssh $ip "sh /home/shellfile/updateall.sh";
    sleep 3s;
    echo -e "\033[32;49;1m [done < 'server.txt'] \033[39;49;0m"
    }&
done < 'server.txt'
wait
fi
#热更
if [[ $TYPE == 'hot' ]];then
while read ip  
do  {
    echo -e "\033[32;49;1m [开始热更新] \033[39;49;0m"
    ssh $ip 'rm -rf /data/update/*';
    echo -e "\033[32;49;1m [删除旧文件完成] \033[39;49;0m"
    rsync -avrzI --files-from=server/data.list server/ root@$ip:/data/update;
    echo -e "\033[32;49;1m [文件上传完成] \033[39;49;0m"
    ssh $ip "sh /home/shellfile/hotupdate.sh";
    sleep 3s;
    echo -e "\033[32;49;1m [done < 'server.txt'] \033[39;49;0m"
    }&
done < 'server.txt'
wait
fi  
#停服
if [[ $TYPE == 'stop' ]];then
    echo -e "\033[31;49;1m [你确定要关闭服务器？] \033[39;49;0m"
    read -n1 -p "Do you want to continue [Y/N]? " answer
    case $answer in
    Y|y)
        while read ip
        do      {
                echo -e "\033[32;49;1m [开始关闭服务器] \033[39;49;0m"
                ssh $ip 'sh /home/shellfile/stopall.sh';
                echo -e "\033[32;49;1m [操作完成] \033[39;49;0m"
                }&
	done < 'server.txt';;
    N|n)
        echo "正在退出";;
    *)
        echo "不正确的输入!退出"
        exit 0
    esac
fi
#开服
if [[ $TYPE == 'start' ]];then
    echo -e "\033[31;49;1m [你确定要开启服务器？] \033[39;49;0m"
    read -n1 -p "Do you want to continue [Y/N]? " answer
    case $answer in
    Y|y)
        while read ip
        do      {
                echo -e "\033[32;49;1m [开始启动服务器] \033[39;49;0m"
                ssh $ip 'sh /home/shellfile/startall.sh';
                echo -e "\033[32;49;1m [操作完成] \033[39;49;0m"
        	}&
	done < 'server.txt';;
    N|n)
        echo "正在退出";;
    *)
        echo "不正确的输入!退出"
        exit 0
    esac
fi  
#检测
if [[ $TYPE == 'check' ]];then
while read ip  
do  {
    ssh $ip 'sh /home/shellfile/checkalive.sh';
    }
done < 'server.txt'
fi  
