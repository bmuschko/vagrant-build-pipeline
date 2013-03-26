group { 'puppet': ensure => 'present' }

exec { "authenticate-packages":
  command => "/usr/bin/wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | /usr/bin/sudo apt-key add -",
}

exec { "retrieve-sonar-list":
  command => "/usr/bin/sudo sh -c 'echo deb http://downloads.sourceforge.net/project/sonar-pkg/deb binary/ > /etc/apt/sources.list.d/sonar.list'",
  require => Exec['authenticate-packages'],
}

exec { "update-package-list":
  command => "/usr/bin/sudo /usr/bin/apt-get update",
  require => Exec['retrieve-sonar-list'],
}

class java_6 {
  package { "openjdk-6-jdk":
    ensure => installed,
    require => Exec["update-package-list"],
  }
}

class sonar {
  package { "sonar":
    ensure => installed,
    require => Exec["update-package-list"],
  }
}

include java_6
include sonar