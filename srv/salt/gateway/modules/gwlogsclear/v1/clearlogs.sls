include:
  - envio.gwlogsclear.install

gwlogsclear_clear_logs_now_instant:
  cmd.script:
    - name: /usr/local/bin/logclear.sh
    - source: salt://files/logclear.sh
    - require:
        - sls: envio.gwlogsclear.install
