# Python main entry point for setup + management

import os
import python.functions as pf
import python.vars as pv
	
def main():
	input("Python main start")
	pf.read_config()
	pf.show_menu(pv.mnuMainFull)
	#pf.run_bash('show_vars; test_func')
	#pf.update_setup()
	#print("Git dir = " + pv.arrconf['gitlocaldir'] + "\n")
	input("Python main end")

if __name__ == "__main__":
	main()
