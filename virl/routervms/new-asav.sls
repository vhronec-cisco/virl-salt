{% set asav = salt['pillar.get']('routervms:asav', False) %}
{% set asavpref = salt['pillar.get']('virl:asav', salt['grains.get']('asav', True)) %}

{% if asav and asavpref %}
asav:
  glance.image_present:
    - profile: virl
    - name: 'asav'
    - container_format: bare
    - min_disk: 0
    - min_ram: 0
    - is_public: True
    - checksum: 076cc1929260af973aaf6606acce9530
    - protected: False
    - disk_format: qcow2
    - copy_from: salt://images/salt/asav932-200.qcow2
    - property-config_disk_type: cdrom
    - property-hw_cdrom_type: ide
    - property-hw_disk_bus: ide
    - property-hw_vif_model: e1000
    - property-release: 9.3.2-200
    - property-serial: 1
    - property-subtype: ASAv

asav flavor delete:
  cmd.run:
    - name: 'nova flavor-delete "asav"'
    - onlyif: nova flavor-list | grep -w "asav"
    - onchanges:
      - glance: asav

asav flavor create:
  module.run:
    - name: nova.flavor_create
    - m_name: 'asav'
    - ram: 2048
    - disk: 0
    - vcpus: 1
    - onchanges:
      - glance: asav
    - require:
      - cmd: asav flavor delete

{% else %}

asav gone:
  glance.image_absent:
  - profile: virl
  - name: 'asav'

asav flavor absent:
  cmd.run:
    - name: 'nova flavor-delete "asav"'
    - onlyif: nova flavor-list | grep -w "asav"
{% endif %}
