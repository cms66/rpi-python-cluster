# Bash functions

source_bash()
{
	# Source setup shell scripts in same directory
	for file in $(find $(dirname -- "$0") -type f -name "*.sh" ! -name $(basename "$0"));
	do
  		source $file;
	done
}
