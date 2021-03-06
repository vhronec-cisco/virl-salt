base:
  '*':
    - common.ubuntu

  '^.{9}virledu.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '^.{9}virl.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '^.{9}virl30.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '^.{9}virl40.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '^.{9}devnet.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '^.*innopod.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '.*cisco.com$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '.*packet.net$':
    - match: pcre
    - common.virl
    - virl.vinstall

  'appcat.virl.qa$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '.*virl.qa$':
    - match: pcre
    - common.virl
    - virl.vinstall


