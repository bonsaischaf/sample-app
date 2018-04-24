echo "creating java application path"
mkdir -p /var/sample-app

echo "install java application"
cp /tmp/sample-app.jar /var/sample-app/sample-app.jar
chown spring-boot:spring-boot /var/sample-app/sample-app.jar
chmod +x /var/sample-app/sample-app.jar

echo "installing systemd service"
cat <<EOF > /etc/systemd/system/sample-app.service;
[Unit]
Description=sample-app
After=syslog.target
[Service]
User=spring-boot
ExecStart=/usr/bin/java -jar /var/sample-app/sample-app.jar
SuccessExitStatus=143
[Install]
WantedBy=multi-user.target
EOF
systemctl enable sample-app.service
