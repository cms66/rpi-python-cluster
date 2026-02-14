# Python functions

import os
import python.vars as pv

def run_bash(func):
	strcmd = "source " + pv.bashfile + "; source_bash; " + func
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

def update_setup():
	strdir = pv.arrconf["gitlocaldir"] + "/" +  pv.arrconf["gitrepo"].strip()
	gitdir = "".join(strdir.splitlines())
	strurl = "https://github.com/" +  pv.arrconf["gituser"] + "/" +  pv.arrconf["gitrepo"] + ".git".strip()
	giturl = "".join(strurl.splitlines())
	cmd = "git pull " + giturl
	os.chdir(gitdir)
	os.system(cmd)
	input("Git setup done, press enter to continue")

