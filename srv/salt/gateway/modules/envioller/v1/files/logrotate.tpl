/var/log/envio/envioller/envioller.log {
	rotate 2
	daily
	compress
	maxsize 50M
	nocreate
	missingok
	postrotate
		if invoke-rc.d envioller status > /dev/null 2>&1; then \
			invoke-rc.d envioller restart > /dev/null 2>&1; \
		fi;
	endscript
}
