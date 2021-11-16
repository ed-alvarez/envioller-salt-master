# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "./map.jinja" import logrotate with context %}

include:
  - .config
  - .install

logrotate:
  service.running:
    - name: {{ logrotate.service }}
    - enable: True
    - require:
      - pkg: logrotate-pkg
      - file: logrotate-config
      - file: logrotate-directory
