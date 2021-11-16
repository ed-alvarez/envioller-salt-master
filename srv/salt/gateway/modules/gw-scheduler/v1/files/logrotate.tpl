/var/log/envio/gw-scheduler/gw-scheduler.log {
	rotate 2
	daily
	compress
	maxsize 50M
	nocreate
	missingok
	postrotate
		if invoke-rc.d gw-scheduler status > /dev/null 2>&1; then \
			invoke-rc.d gw-scheduler restart > /dev/null 2>&1; \
		fi;
	endscript
}
