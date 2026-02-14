# Bash functions

source_bash()
{
	# Source setup shell scripts in same directory
	for file in $(find $(dirname -- "$0") -type f -name "*.sh" ! -name $(basename "$0"));
	do
  		source $file;
	done
}

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
