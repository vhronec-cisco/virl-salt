{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}

include:
  - common.numa

qemu_kvm unhold:
  module.run:
    - name: pkg.unhold
    - m_name: qemu-kvm
    - onlyif: ls /usr/bin/qemu-system-x86_64

/usr/bin/kvm:
  file.managed:
  {% if kilo %}
    - source: "salt://openstack/nova/files/kilo.kvm"
  {% else %}
    - source: "salt://openstack/nova/files/kvm"
  {% endif %}
    - force: True
    - mode: 0755

/usr/bin/kvm.real:
  file.symlink:
    - target: /usr/bin/qemu-system-x86_64
    - mode: 0755
    - require:
      - file: /usr/bin/kvm

qemu prime:
  pkg.installed:
    - force_conf_new: True
    - force_yes: True
    - aggregate: False
    - refresh: True
    - version: 2.0.0+dfsg-2ubuntu1.21
    - name: qemu-kvm

qemu-system:
  pkg.installed:
    - force_conf_new: True
    - force_yes: True
    - aggregate: False
    - refresh: False
    - version: 2.0.0+dfsg-2ubuntu1.21
    - name: qemu-system-x86

qemu:
  pkg.installed:
    - force_conf_new: True
    - force_yes: True
    - refresh: False
    - aggregate: False
    - onfail:
      - pkg: qemu-system
      - pkg: qemu prime
    - pkgs:
      - qemu-system-x86=2.0.0+dfsg-2ubuntu1.21
      - qemu-kvm=2.0.0+dfsg-2ubuntu1.21

libvirt install:
  pkg.installed:
    - name: libvirt-bin
    - aggregate: False
    - skip_verify: True
    - refresh: False

kvm virl version:
  file.managed:
    - name: /usr/bin/kvm
    - onlyif: ls /usr/bin/kvm.real
    - source: "salt://openstack/nova/files/kvm"
    - mode: 0755

uncomment min vnc port:
  file.uncomment:
    - name: /etc/libvirt/qemu.conf
    - regex: remote_display_port_min.*
    - require:
      - pkg: libvirt install

alter min vnc port:
  file.replace:
    - name: /etc/libvirt/qemu.conf
    - pattern: remote_display_port_min = 59..
    - repl: remote_display_port_min = 5950
    - require:
      - file: uncomment min vnc port

qemu hold:
  apt.held:
    - name: qemu-kvm

