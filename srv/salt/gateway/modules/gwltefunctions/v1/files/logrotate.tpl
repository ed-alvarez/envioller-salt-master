/var/log/ethppp_networkswitch.log {
	rotate 14
	daily
	compress
	maxsize 50M
	nocreate
	missingok
	postrotate
		if invoke-rc.d ethppp_networkswitch status > /dev/null 2>&1; then \
			invoke-rc.d ethppp_networkswitch restart > /dev/null 2>&1; \
		fi;
	endscript
}
