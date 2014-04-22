Vagrant.configure("2") do |config|
  config.vm.box = "berendt/ubuntu-14.04-amd64"
  config.vm.provision :shell, :path => "scripts/install.sh"
  config.vm.network :forwarded_port, host: 5444, guest: 5984
end