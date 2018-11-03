#bin/sh

# 定时切割Nginx的日志脚本
# 例: /etc/nginx/logs/{ Y }/{ m }/{ Ymd }_Access.log

NGINX=/usr/sbin/nginx
LOGS_PATH=/etc/nginx/logs

# 创建目录
NEW_PATH=$LOGS_PATH/$(date -d @$(($(date +%s) - 86400)) +%Y)/$(date -d @$(($(date +%s) - 86400)) +%m)
mkdir -p $NEW_PATH

# 移动日志 -- Access/Error
# 判断成功日志是否存在
ACCESS=$LOGS_PATH/access.log
if [ -f $ACCESS ]; then
  mv $ACCESS $NEW_PATH/$(date -d @$(($(date +%s) - 86400)) +%Y%m%d)_Access.log
fi

# 判断失败日志是否存在
ERROR=$LOGS_PATH/error.log
if [ -f $ERROR ]; then
  mv $ERROR $NEW_PATH/$(date -d @$(($(date +%s) - 86400)) +%Y%m%d)_Error.log
fi

# 重启 - reboot
PID=$LOGS_PATH/nginx.pid
if [ -f $PID ]; then
  $NGINX -s reload
else
  $NGINX
fi
