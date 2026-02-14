# Python main entry point for setup + management

import os
import python.functions as pf
import python.vars as pv
	
def main():
	pf.read_config()
	pf.show_menu(pv.mnuMainFull)

if __name__ == "__main__":
	main()
