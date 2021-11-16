#
#include:
#  - .install

configsbackup_now_instant:
  cmd.run:
    - name: 'sudo /usr/local/bin/configsbackup.sh 1'
#RUN WITH THE PARAMETER 1 AT THE END OF SCRIPT TO SKIP THE SCRIPT'S AUTO UPLOAD FEATURE


#    - require:
#        - sls: gateway.modules.configsbackup.v1.install
#
#configsbackup_run_backup_script_create_archive:
#  cmd.run:
#    - name: 'sudo /usr/local/bin/configsbackup.sh'
#mkdir -p /home/debian/configsbackup
#sudo tar -zcvf "/home/debian/configsbackup/envio_config_$(date '+%Y-%m-%d_%H_%M_%S').tar.gz" /etc/envio

configsbackup_push_configs_archive_to_master:
  module.run:
    - name: cp.push_dir
    - path: '/home/debian/configsbackup/'
#    - remove_source: True
    - glob: '*.tar.gz'

configsbackup_remove_dir:
  file.absent:
    - names:
        - /home/debian/configsbackup/
    - require:
        - configsbackup_push_configs_archive_to_master
