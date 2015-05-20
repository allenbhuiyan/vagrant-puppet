# -*- mode: ruby -*-
# vi: set ft=ruby :
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|


  unless Vagrant.has_plugin?("vagrant-hostmanager")
    raise 'vagrant-hostmanager plugin is not installed!'
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  set_proxy = false
  set_proxy_env = ENV['VAGRANT_SET_PROXY']
  proxy = set_proxy_env ? set_proxy_env : set_proxy

  if proxy == 'true'
    if File.exist?('scripts/set-proxy.sh')
      config.vm.provision "shell", path: "scripts/set-proxy.sh"
    end
  end

  config.vm.provider :virtualbox do |virtualbox, override|
    override.vm.box = "vStone/centos-6.x-puppet.3.x"
    virtualbox.customize ["modifyvm", :id, "--memory", 3072]
  end

  config.vm.provider :lxc do |lxc, override|
    override.vm.box = "visibilityspots/centos-6.x-puppet-3.x"
  end

  config.vm.define :puppetmaster do |puppetmaster|
    puppetmaster.vm.host_name = "puppet"
    puppetmaster.vm.synced_folder "hieradata", "/etc/hiera", type: "rsync",
      rsync__chown: false
    puppetmaster.vm.synced_folder "puppet/environments/production", "/etc/puppet/environments/production", type: "rsync",
      rsync__chown: false
    puppetmaster.vm.provider :lxc do |lxc|
      lxc.container_name = 'dev-puppetmaster'
    end
    puppetmaster.vm.provider :virtualbox do |virtualbox, override|
      override.vm.network "private_network", ip: "10.0.5.2"
      virtualbox.customize ["modifyvm", :id, "--memory", 3072]
    end
    puppetmaster.vm.provision "shell", path: "scripts/puppetmaster.sh"
    if Vagrant.has_plugin?("vagrant-serverspec")
      puppetmaster.vm.provision :serverspec do |spec|
        spec.pattern = 'spec/puppetmaster/*_spec.rb'
      end
    end
  end

  config.vm.define :node01 do |node01|
    node01.vm.host_name = "node01"

    node01.vm.provider :lxc do |lxc|
      lxc.container_name = 'dev-node01'
    end

    node01.vm.provider :virtualbox do |virtualbox, override|
      override.vm.network "private_network", ip: "10.0.5.3"
      unless File.exist?('nfs.vdi')
	virtualbox.customize ['createhd', '--filename', "nfs.vdi", '--size', 1536 ]
      end
      virtualbox.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', "nfs.vdi"]
    end

    node01.vm.provision "puppet_server" do |puppet|
      default_env = 'production'
      ext_env = ENV['VAGRANT_PUPPET_ENV']
      env = ext_env ? ext_env : default_env
      puppet.puppet_server = "puppet"
      puppet.options = ["--environment", "#{env}", "--test"]
    end
    if Vagrant.has_plugin?("vagrant-serverspec")
      node01.vm.provision :serverspec do |spec|
        spec.pattern = 'spec/node01/*_spec.rb'
      end
    end

  end

  config.vm.define :node02 do |node02|
    node02.vm.host_name = "node02"

    node02.vm.provider :lxc do |lxc|
      lxc.container_name = 'dev-node02'
    end

    node02.vm.provider :virtualbox do |virtualbox, override|
      override.vm.network "private_network", ip: "10.0.5.4"
    end

    node02.vm.provision "puppet_server" do |puppet|
      default_env = 'production'
      ext_env = ENV['VAGRANT_PUPPET_ENV']
      env = ext_env ? ext_env : default_env
      puppet.puppet_server = "puppet"
      puppet.options = ["--environment", "#{env}", "--test"]
    end
    if Vagrant.has_plugin?("vagrant-serverspec")
      node02.vm.provision :serverspec do |spec|
        spec.pattern = 'spec/node02/*_spec.rb'
      end
    end
  end

end

