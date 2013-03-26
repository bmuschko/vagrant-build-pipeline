group { 'puppet': 
  ensure => 'present' 
}

exec { "authenticate-packages":
  command => "/usr/bin/wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | /usr/bin/sudo apt-key add -",
}

exec { "retrieve-jenkins-list":
  command => "/usr/bin/sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'",
}

exec { "update-package-list":
  command => "/usr/bin/sudo /usr/bin/apt-get update",
}

class java_6::install {
  package { "openjdk-6-jdk":
    ensure => installed,
  }
}

class jenkins::install {
  package { "jenkins":
    ensure => installed,
  }

  service { "jenkins":
    ensure => running,
  }
}

Exec["update-package-list"] -> Class["java_6::install"]
Exec["authenticate-packages"] -> Exec["retrieve-jenkins-list"] -> Exec["update-package-list"] -> Class["jenkins::install"]

include java_6::install
include jenkins::install