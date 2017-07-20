class cosmos::httpsproxy ($certs = ['/etc/ssl/private/server.pem']) {
   include ufw
   include pound
   package {'ssl-cert': ensure => latest }
   file {'/etc/ssl/private/server.pem':
      ensure => file,
      source => '/etc/ssl/private/snakeoil.pem',
      replace => false,
   }
   exec {'generate-snakeoil':
      command => 'cat /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/certs/ssl-cert-snakeoil.pem > /etc/ssl/private/snakeoil.pem',
      notify => File['/etc/ssl/private/server.pem'],
      creates => '/etc/ssl/private/snakeoil.pem',
      require => Package['ssl-cert'],
   }
   Exec['generate-snakeoil'] -> File['/etc/ssl/private/server.pem']
   pound::entry {"$name-httpsproxy-443":
      listen_ip => '0.0.0.0',
      listen_port => '443',
      listen_protocol => 'ListenHTTPS',
      head_require => 'Host:.*',
      backend_ip => '127.0.0.1',
      backend_port => '80',
      ssl_ciphers  => "EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:!aNULL:!eNULL:!LOW:!3DES:!WEAK:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ECDSA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA",
      server_cert => $certs
   }
   include augeas
   augeas { "etc_default_pound":
      changes => [
         "set /files/etc/default/pound/startup 1",
      ],
   }
   ufw::allow { "allow-pound-https":
      ip   => 'any',
      port => '443'
   }
}
