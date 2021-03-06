{% set hostname = salt['grains.get']('salt_id', 'virltest') %}
{% set salt_domain = salt['grains.get']('append_domain', 'virl.info') %}

include:
  - common.salt-master.cluster-key


virl_packet repo:
  git.latest:
    - user: virl
    - name: https://github.com/Snergster/virl_packet.git
    - target: /home/virl/virl_packet

install pwgen:
  pkg.installed:
    - refresh: true
    - name: pwgen

pem minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/minion.pem
    - source: /etc/salt/pki/minion/minion.pem
    - user: virl
    - group: virl
    - mode: 0555

pub minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/minion.pub
    - source: /etc/salt/pki/minion/minion.pub
    - user: virl
    - group: virl
    - mode: 0755

sign minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/master_sign.pub
    - source: /etc/salt/pki/minion/master_sign.pub
    - user: virl
    - group: virl
    - mode: 0755

working variable file:
  file.copy:
    - user: virl
    - group: virl
    - name: /home/virl/virl_packet/variables.tf
    - source: /home/virl/virl_packet/variables.tf.orig
    - force: true

working password file:
  file.copy:
    - user: virl
    - group: virl
    - name: /home/virl/virl_packet/passwords.tf
    - source: /home/virl/virl_packet/passwords.tf.orig
    - force: true

working api file:
  file.copy:
    - user: virl
    - group: virl
    - name: /home/virl/virl_packet/settings.tf
    - source: /home/virl/virl_packet/settings.tf.orig
    - force: false

guest pass replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: 321guest123
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

uwmadmin pass replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: '321uwmp123'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

os pass replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: '123pass321'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

mysql pass replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: '123mysq321'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

os token replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: '123token321'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

hostname replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: 'virltest'
    - repl: '{{hostname}}'

id replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: 'badsaltid'
    - repl: '{{hostname}}'

domain replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: '= "virl.info"'
    - repl: '= "{{salt_domain}}"'

virl tf ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/virl.tf
    - create: false
    - user: virl
    - group: virl

virl tf backup ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/virl.tf.bak
    - create: false
    - user: virl
    - group: virl

variables tf ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/variables.tf
    - create: false
    - user: virl
    - group: virl

variables tf backup ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/variables.tf.bak
    - create: false
    - user: virl
    - group: virl

passwords tf ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/passwords.tf
    - create: false
    - user: virl
    - group: virl

passwords tf backup ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/passwords.tf.bak
    - create: false
    - user: virl
    - group: virl


