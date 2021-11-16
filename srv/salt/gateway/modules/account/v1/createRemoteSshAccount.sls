#
# This state sets the remote-ssh user at gateway and generate its own
# credentials used to ssh remotely
#

{%- set userid = "remotessh" %}
{%- set gw_id = salt['grains.get']('id').split('.')[0] %}
{%- set ssh_key_name = userid + "-" + gw_id %}

# create user

service_account_{{ userid }}:
  user.present:
    - name: {{ userid }}
    - fullname: {{ userid }}
    - shell: /bin/bash
    - home: /home/{{ userid }}

# generate ssh keys, this is run in-place instead of sending from pllar to
# minion

create_ssh_folder_{{ userid }}:
  file.directory:
    - name: /home/{{ userid }}/.ssh
    - user: {{ userid }}
    - group: {{ userid }}
    - dir_mode: "0700"
    - file_mode: "0700"
    - require:
      - user: service_account_{{ userid }}

generate_ssh_key_{{ userid }}:
  cmd.run:
    - name: |
        ssh-keygen -q -N "" -t rsa -b 4096 -C {{ ssh_key_name }} -f /home/{{ userid }}/.ssh/id_rsa
        && echo "new ssh key par generated in gateway for user '{{ userid }}'"
    - runas: {{ userid }}
    - creates: /home/{{ userid }}/.ssh/id_rsa
    - require:
      - file: create_ssh_folder_{{ userid }}
