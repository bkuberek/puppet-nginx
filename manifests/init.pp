class nginx(
  $backports = false
) {
  if $backports {
    apt::pin { 'nginx':
      ensure     => present,
      packages   => 'nginx',
      priority   => 700,
      release    => 'squeeze-backports'
    }
  }

  package { 'nginx':
    ensure => installed
  }

  file { ['/var/www/', '/var/www/cache', '/var/www/cache/tmp']:
    ensure => directory,
    owner  => 'www-data',
  }

  file { '/etc/nginx/nginx.conf':
    source  => 'puppet:///modules/nginx/nginx.conf',
    mode    => '0644',
    require => [File['/var/www/cache/tmp'], Package['nginx']],
    notify  => Exec['nginx_reload'],
  }

  service { 'nginx':
    name        => 'nginx',
    enable      => true,
    ensure      => running,
    hasstatus   => true,
    hasrestart  => true,
    provider    => 'debian',
    subscribe   => Package['nginx'],
  }
}