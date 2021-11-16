#
# this will remove rc-local as it has been deprecated in latest debian releases 
#

rclocal_service_stop:
  service.dead:
    - name: rc-local
    - enable: False