define prosody::virtualhost(
  $ensure='present',
  $ssl_key='UNSET',
  $ssl_cert='UNSET'
) {
  if (($ssl_key != 'UNSET') and ($ssl_cert == 'UNSET')) {
    fail('The prosody::virtualhost type needs both ssl_key *and* ssl_cert set')
  }
  if (($ssl_key == 'UNSET') and ($ssl_cert != 'UNSET')) {
    fail('The prosody::virtualhost type needs both ssl_key *and* ssl_cert set')
  }

  if (($ssl_key != 'UNSET') and ($ssl_cert != 'UNSET')) {
    $config_requires = [File[$ssl_key], File[$ssl_cert], Class[prosody::package]]
  }
  else {
    $config_requires = Class[prosody::package]
  }

  file { "${name}.cfg.lua":
    ensure  => $ensure,
    require => $config_requires,
    path    => "/etc/prosody/conf.avail/${name}.cfg.lua",
    content => template('prosody/virtualhost.cfg.erb'),
    notify  => Service[prosody];
  }

  $cfg_ensure = $ensure ? {
      'present' => link,
      'absent'  => absent,
    }

  file { "/etc/prosody/conf.d/${name}.cfg.lua":
    ensure  => $cfg_ensure,
    target  => "/etc/prosody/conf.avail/${name}.cfg.lua",
    notify  => Service[prosody],
    require => File["${name}.cfg.lua"];
  }
}
