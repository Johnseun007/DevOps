class webserver(
                $packagename = hiera('packagename'),
                $configfile = hiera('configfile'),
                $configsource = hiera('configsource'),
                $vhostfile = hiera('vhostfile')
                ) {

        package { 'webserver-package':
                name   => $packagename,
                ensure => present
        }

        file { 'config-file':
                path   => $configfile,
                ensure => file,
                source => $configsource,
                require => Package['webserver-package'],
                notify  => Service['webserver-service'],
        }

        file { 'vhost-file':
                path    => $vhostfile,
                ensure  => file,
                content => template('webserver/vhost.conf.erb'),
                require => Package['webserver-package'],
                notify  => Service['webserver-service'],
        }

        service { 'webserver-service':
                name        => $packagename,
                ensure      => running,
                enable      => true,
                hasrestart  => true,
                require     => [ File['config-file'], File['vhost-file'] ],
        }
}

