# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "lucid64"
  config.vm.box_url = "http://files.vagrantup.com/lucid64.box"

  config.vm.define "jenkins" do |jenkins|
    jenkins.vm.network :hostonly, "33.33.33.10"
    jenkins.vm.host_name = "jenkins.local"
    jenkins.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "jenkins.pp"
    end
  end

  #config.vm.define "sonar" do |sonar|
  #  sonar.vm.network :hostonly, "33.33.33.11"
  #  sonar.vm.host_name = "sonar.local"
  #  sonar.vm.provision :puppet do |puppet|
  #    puppet.manifests_path = "manifests"
  #    puppet.manifest_file = "sonar.pp"
  #  end
  #end
end
