# Python functions

import os
import python.vars as pv

def show_user():
	print("Username: " + pv.usrname + "\n")
	print("User ID: " + pv.usrid + "\n")
	print("Group ID: " + pv.usrgid + "\n")
	input("Done, press enter to continue")
	
def run_bash(func):
	#bashfile = os.path.dirname(__file__) + "/bash/functions.sh".strip()
	bashfile = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'bash/functions.sh')
	strcmd = "source " + bashfile + "; source_bash; read_config; " + func
	os.system(strcmd)
	input("Command done, press enter to continue")

def read_config():
	conf = "/boot/firmware/custom.conf"
	if os.path.exists(conf):
		with open(conf) as f:
			for line in f:
				key = line.split('=')[0]
				val = line.split('=')[1]
				pv.arrconf[key] = val

def show_menu(menu):
	prompt = "Select option: "
	while True:
		os.system("clear")
		for item in menu: # Show menu
			if menu.index(item) == 0: # Print underlined title + hostname
				print("\u0332".join(item.split("#")[0] + " (" + pv.hstname + ")"))
			else:
				print(f"{menu.index(item)})\t {item.split("#")[0]}".expandtabs(2))
		try: # Process input
			value = input(prompt)
			ival = int(value)
			if 0 < ival < len(menu): # Action selected
				if ival == (len(menu) - 1): # Last menu item = Back/Quit
					break
				else:
					act = menu[ival].split("#")[1]
					exec(f"{act}")                           
			else:
				input("Invalid integer " + str(ival) + " , press enter to continue")
				continue
		except ValueError:
			if value.lower() == "b": # Back selected
				break
			elif value.lower() == "q": # Quit selected
				break
			else:
				input("Invalid input " + value + " , press enter to continue")
				continue

def update_setup():
	strdir = pv.arrconf["gitlocaldir"] + "/" +  pv.arrconf["gitrepo"].strip()
	gitdir = "".join(strdir.splitlines())
	strurl = "https://github.com/" +  pv.arrconf["gituser"] + "/" +  pv.arrconf["gitrepo"] + ".git".strip()
	giturl = "".join(strurl.splitlines())
	cmd = "git pull " + giturl
	os.chdir(gitdir)
	os.system("git stash")
	os.system(cmd)
	input("Git setup done, press enter to continue")

def update_system():
	os.system("sudo apt-get -y update")
	os.system("sudo apt-get -y full-upgrade")
	input("System update done, press enter to continue")
