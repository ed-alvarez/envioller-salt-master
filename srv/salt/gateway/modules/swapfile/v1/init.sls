/swapfile:
  cmd.run:
    - name: umask 0077 && fallocate -l 256M /swapfile && mkswap /swapfile
    - onlyif:
        - test ! -e /swapfile
  mount.swap:
    - persist: true
    - require:
        - cmd: /swapfile
