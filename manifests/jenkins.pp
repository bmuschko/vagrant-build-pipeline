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

class git::install {
  package { "git-core":
    ensure => installed,
  }
}

class git::username {
  exec { "git-username":
    command => "/usr/bin/sudo git config --global user.name 'jenkins'",
  }
}

class git::email {
  exec { "git-email":
    command => "/usr/bin/sudo git config --global user.email 'jenkins@xxx.x'",
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

class jenkins::restart {
  exec { "jenkins-restart":
    command => "/usr/bin/sudo /etc/init.d/jenkins restart",
    require => Class["jenkins::install"],
  }
}

define jenkinsplugin($plugin_name = $title) {
  $jenkins_plugin_dir = "/var/lib/jenkins/plugins"
  $hpi_file = "${plugin_name}.hpi"
  
  exec { "wget-${plugin_name}-plugin":
    command => "/usr/bin/wget -nv --no-check-certificate http://updates.jenkins-ci.org/latest/${hpi_file} -P ${jenkins_plugin_dir}",  
    require => Class["jenkins::install"],
  }
  
  file { $hpi_file:
    path => "${jenkins_plugin_dir}/${hpi_file}",
    ensure => file,  
    require => Exec["wget-${plugin_name}-plugin"],
  }  
}

jenkinsplugin { 'git': }
jenkinsplugin { 'git-client': }
jenkinsplugin { 'gradle': }
jenkinsplugin { 'jacoco': }
jenkinsplugin { 'parameterized-trigger': }
jenkinsplugin { 'token-macro': }
jenkinsplugin { 'build-name-setter': 
  require => Jenkinsplugin['token-macro']
}
jenkinsplugin { 'clone-workspace-scm': }
jenkinsplugin { 'build-pipeline-plugin': }

# Install Java
Exec["update-package-list"] -> Class["java_6::install"]
# Install Git
Exec["update-package-list"] -> Class["git::install"] -> Class["git::username"] -> Class["git::email"]
# Install Jenkins
Exec["authenticate-packages"] -> Exec["retrieve-jenkins-list"] -> Exec["update-package-list"] -> Class["jenkins::install"]
# Install plugins and restart Jenkins
Class["jenkins::install"] -> Jenkinsplugin["git"] -> Jenkinsplugin["git-client"] -> Jenkinsplugin["gradle"] -> Jenkinsplugin["jacoco"] -> Jenkinsplugin["build-name-setter"] -> Jenkinsplugin["clone-workspace-scm"] -> Jenkinsplugin["parameterized-trigger"] -> Jenkinsplugin["build-pipeline-plugin"] -> Class["jenkins::restart"]

include java_6::install
include git::install
include git::username
include git::email
include jenkins::install
include jenkins::restart