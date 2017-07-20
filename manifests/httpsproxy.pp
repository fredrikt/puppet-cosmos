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
      ssl_ciphers  => "TLSv1.2:TLSv1.1:!SSLv3:!SSLv2:DHE-RSA-CAMELLIA256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DES-CBC3-SHA:!ADH:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED",
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
