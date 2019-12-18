cp /usr/bin/nginx.conf.template /tmp/nginx.conf
cp /usr/bin/nginx.conf.master /tmp/nginx.conf.master
sh printnodes.sh >> /dev/null
if [ $? -eq 0 ]; then
sh printnodes.sh| while read line
do
name=$(echo $line | awk '{ print $1 }')
role=$(echo $line | awk '{ print $3 }')
if [ "$name" != "NAME" ]; then
if [ "$role" == "master" ]; then
sed -i "s/        # server masterservername:6443;/        server $name:6443;\n        # server masterservername:6443;/g" /tmp/nginx.conf
fi
sed -i "s/        # server servername:30036;/        server $name:30036;\n        # server servername:30036;/g" /tmp/nginx.conf
sed -i "s/        # server servername:30037;/        server $name:30037;\n        # server servername:30037;/g" /tmp/nginx.conf
sed -i "s/        # server servername:30038;/        server $name:30038;\n        # server servername:30038;/g" /tmp/nginx.conf
fi
done
cat /tmp/nginx.conf
else
cat /tmp/nginx.conf.master
fi
