s3bucket="upgrad-punit"
name=”punit”
sudo apt-get update -y
if [[ apache2 != $(dpkg --get-selections apache2 | awk '{print $1}') ]];
then
	sudo apt install apache2 -y
fi

running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')
if [[ running != ${running} ]]; 
then
	sudo systemctl start apache2
fi
enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != ${enabled} ]];
then
	sudo systemctl enable apache2
fi
timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log
aws=$(apt list | grep "awscli/bionic-updates 1.18.69-1ubuntu0.18.04.1 all")
if [[ aws != ${aws} ]];
then 
        sudo apt-get install awscli -y
else 
        echo "awscli already install"
fi	
if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]];
then
	aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3bucket}/${name}-httpd-logs-${timestamp}.tar
fi

