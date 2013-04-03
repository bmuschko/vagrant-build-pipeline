group { 'puppet': 
  ensure => 'present' 
}

$sonar_version = '3.5'
$tmp_dir = '/tmp'

exec { "wget-sonar-dist":
  command => "/usr/bin/wget -q http://dist.sonar.codehaus.org/sonar-${sonar_version}.zip -P ${tmp_dir}",
}

exec { "unzip-sonar":
  command => "/usr/bin/sudo /usr/bin/unzip ${tmp_dir}/sonar-${sonar_version}.zip -d /usr/local",
}

exec { "start-sonar":
  command => "/usr/bin/sudo /usr/local/sonar-${sonar_version}/bin/linux-x86-64/sonar.sh start"
}

exec { "update-package-list":
  command => "/usr/bin/sudo /usr/bin/apt-get update",
}

class unzip::install {
  package { "unzip":
    ensure => installed,
  }
}

class java_6::install {
  package { "openjdk-6-jdk":
    ensure => installed,
  }
}

# Install Java
Exec["update-package-list"] -> Class["java_6::install"]
# Install Sonar
Class["unzip::install"] -> Exec["wget-sonar-dist"] -> Exec["unzip-sonar"] -> Class["java_6::install"] -> Exec["start-sonar"]

include java_6::install
include unzip::install