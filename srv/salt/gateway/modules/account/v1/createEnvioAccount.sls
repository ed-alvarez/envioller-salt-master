#
# This state sets the operating system user at gateway for modules installation
#

{%- if salt['grains.get']('os_family') == 'Debian' %}

# TODO: gateway user should be named independently from OS
# for example 'envio'
{%- set userid = "debian" %}

service_account_{{ userid }}:
  user.present:
    - name: {{ userid }}
    - fullname: {{ userid }}
      # For Linux, the hash can be generated with: mkpasswd -m sha-256
      # TODO: move this property to pillar
    - password: $5$YHkABYATFbF$VoE.I1/8yOJ7jD9onVdjkLtPj4coJzIiQAkmN3Town8
    - shell: /bin/bash
    - home: /home/{{ userid }}
    - groups: 
      - sudo
      
{%- endif %}