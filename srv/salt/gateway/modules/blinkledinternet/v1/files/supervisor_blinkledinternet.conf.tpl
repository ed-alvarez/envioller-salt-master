[program:blinkledinternet]
user={{ user }}
directory={{ install_dir }}
command=bash -c 'sleep 10 && {{ install_dir }}/BlinkLEDInternet'
