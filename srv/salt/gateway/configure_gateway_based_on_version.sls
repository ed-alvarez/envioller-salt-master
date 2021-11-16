#
# This initialization file matchs the version configuration file
# with the file revision set at grain 'gw-revision', for example
# if grain is "v2020.7.1" this file will be rendered as
#
# include:
#   - v2020_7_1
#
# and this will include all the modules configured in that file.
# This is a clean way to specify which modules are loaded and 
# which one are not for a given revision.
#
# If grain 'gw-revision' is not set, default value will be 'v1'
#
# Dots are replaced by '_' as saltstack does not allow dots except
# for suffix 'sls'
#

include:
  - .versions.v{{ salt['grains.get']('envio_distro_version', '1').replace(".", "_") }}