#!/usr/bin/python
#__author__ = 'ejk'

import ConfigParser
import salt.client
from os import path

opts = salt.config.minion_config('/etc/salt/minion')
opts['file_client'] = 'local'
opts['fileserver_backend'] = 'roots'
caller = salt.client.Caller(mopts=opts)
Config = ConfigParser.ConfigParser()

virlconfig_file = '/etc/virl.ini'
if path.exists(virlconfig_file):
    Config.read('/etc/virl.ini')
else:
    print "No config exists at /etc/virl.ini."
    exit(1)

if __name__ == "__main__":
    vgrains = {}
    for name, value in Config.items('DEFAULT'):
        if value.lower() == 'true':
            vgrains[name] = True
        elif value.lower() == 'false':
            vgrains[name] = False
        else:
            vgrains[name] = value
    caller.sminion.functions['grains.setvals'](vgrains)
