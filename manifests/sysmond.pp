# This class installs the New Relic system monitor
class newrelic::sysmond (
  $license,
) {

  case $::osfamily {

    'Debian': {
      include apt
    
      apt::source { "newrelic":
        release => "newrelic",
        repos => "non-free",
        location => "http://apt.newrelic.com/debian/",
        include_src => false,
        key => "548C16BF",
        key_server => "subkeys.pgp.net",
      }
    
      package { "newrelic-sysmond":
        require => Apt::Source['newrelic'],
        ensure => latest,
        notify => Exec['add_license_to_newrelic'],
      }
    }

    default: { notice("newrelic::sysmond: $::osfamily is not fully supported yet") }

  }

  service { "newrelic-sysmond":
    ensure => running,
    require => Package['newrelic-sysmond'],
  }

  exec { 'add_license_to_newrelic':
    refreshonly => true,
    path => "/usr/sbin/nrsysmond-config --set license_key=$license",
    unless => "grep $license /etc/newrelic/nrsysmond.cfg >/dev/null"
  }

}
