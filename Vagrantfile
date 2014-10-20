Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, :path => "scripts/install-ubuntu.sh"
  config.vm.network :forwarded_port, host: 5444, guest: 5984
end
