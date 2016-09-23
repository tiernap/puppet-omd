/*
 * This is a class that you can use to create an apache VHOST, that will
 * - listen on a defined port
 * - activate and force SSL for every OMD site provided
 * - allow access to a secure and authenticate (restrict using certificates ) an HTTPS version of the unsecure http version, by using user certificates as the user names thanks to fakebasicauth
 *
 * AND :
 * - for each 'site' given as mandatory argument, creates a < Location /> requiring the users created in the multisite htpasswd file
 */

 class omd::ssl::vhost (
  $port=443,
  $sites, #this is a list of sites
  $ssl_cert='/etc/grid-security/hostcert.pem',
  $ssl_key='/etc/grid-security/hostkey.pem',
  $ca_dir='/etc/grid-security/certificates',
  $sslciphersuite='ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS',
  $ssl_force_client_cert=true, #this is the "SSLVerifyClient require" option. If false, this will be defined as SSLVerifyClient optional
  $admin_mail='admin mail not set',
  $priority='zzzz'

 )
{
   case $::osfamily {
    debian : { 
      
      exec {'/usr/sbin/a2enmod ssl':
        require => Package[omd],
        creates => '/etc/apache2/mods-enabled/ssl.conf',
      }
      
      exec {'/usr/sbin/a2enmod headers':
        require => Package[omd],
        creates => '/etc/apache2/mods-enabled/headers.load',
      }
      exec {'/usr/sbin/a2enmod proxy':
        require => Package[omd],
        creates => '/etc/apache2/mods-enabled/proxy.load',
      }
      exec {'/usr/sbin/a2enmod proxy_http':
        require => Package[omd],
        creates => '/etc/apache2/mods-enabled/proxy_http.load',
      }
      file { "/etc/apache2/sites-available/zzzz_omd_ssl.conf":
        require => Exec['/usr/sbin/a2enmod ssl'],
        content => template('omd/ssl/vhost.erb'),
        mode    => '644',
        notify  => Service[omd],
      }

      exec {'/usr/sbin/a2ensite zzzz_omd_ssl':
        require => File['/etc/apache2/sites-available/zzzz_omd_ssl.conf'],
        creates => '/etc/apache2/sites-enabled/zzzz_omd_ssl.conf',
        notify  => Service[omd],
      }
    }

    redhat : { 
      file { '/etc/httpd/conf.d/zzzz_omd_ssl.conf':
        require => Package[httpd],
        content => template('omd/ssl/vhost.erb'),
        mode => '644',
        notify => Service[httpd],
      }
    }

    default : { fail("unsupported os family : $::osfamily")}
  }
 }

