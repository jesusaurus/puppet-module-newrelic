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
      }
    }

    'RedHat': {
      yumrepo { "newrelic":
        enabled   => '1',
        gpgcheck  => '1',
        gpgkey    => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-NewRelic",
        baseurl   => 'http://yum.newrelic.com/pub/newrelic/el5/$basearch',
        descr     => 'New Relic packages for Enterprise Linux - $basearch',
        require   => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-NewRelic'],
      }

      file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-NewRelic":
        ensure => present,
        owner  => root,
        group  => root,
        mode   => 0644,
        source => "puppet:///modules/newrelic/RPM-GPG-KEY-NewRelic"
      }

      package { "newrelic-sysmond":
        require => Yumrepo['newrelic'],
        ensure  => latest,
      }
    }

    default: { notice("newrelic::sysmond: $::osfamily is not fully supported yet") }

  }

  service { "newrelic-sysmond":
    ensure => running,
    require => Exec['add_license_to_newrelic'],
  }

  exec { 'add_license_to_newrelic':
    refreshonly => true,
    command     => "/usr/sbin/nrsysmond-config --set license_key=$license",
    unless      => "/bin/grep -q $license /etc/newrelic/nrsysmond.cfg",
    require     => Package['newrelic-sysmond'],
  }

}
# vim: sts=2 sw=2 et #
