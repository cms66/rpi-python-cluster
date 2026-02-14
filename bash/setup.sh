update_hosts()
{
	input="/boot/firmware/hosts.txt"
	echo "127.0.0.1	localhost" > /etc/hosts
	echo "127.0.1.1	$(hostname)" >> /etc/hosts
	echo "# Local nodes" >> /etc/hosts
	while IFS= read -r line
	do
  		echo "$line" >> /etc/hosts
	done < "$input"
}

setup_fail2ban()
{
	printf "%s\n" "Configuring fail2ban"
	cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	# Setup ssh rules
	strssh="filter	= sshd\n\
banaction = iptables-multiport\n\
bantime = -1\n\
maxretry = 3\n\
findtime = 24h\n\
backend = systemd\n\
journalmatch = _SYSTEMD_UNIT=ssh.service + _COMM=sshd\n\
enabled = true\n"
	sed -i "s/backend = %(sshd_backend)s/$strssh/g" /etc/fail2ban/jail.local
	printf "%s\n" "Fail2ban setup complete"
}

create_venv()
{
	usrname=$(logname)
	printf "%s\n" "Creating python Virtual Environment"
	python -m venv --system-site-packages /home/$usrname/.venv
  	# Create Bash shortcuts to activate/deactivate Virtual Envirnment
	echo "alias mvp=\"source ~/.venv/bin/activate\"" >> /home/$usrname/.bashrc
	echo "alias dvp=\"deactivate\"" >> /home/$usrname/.bashrc
	chown -R $usrname:$usrname /home/$usrname/.venv
	printf "%s\n" "Python Virtual Environment created"
}
