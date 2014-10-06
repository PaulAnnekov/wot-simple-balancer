Vagrant.require_version ">= 1.5.0"

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "chef/debian-7.4"

  config.vm.provider "virtualbox" do |v|
    v.memory = 256
  end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "10.0.0.2"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder.
  config.vm.synced_folder "balancer/", "/home/balancer"

  # Will remove error "stdin is not tty" but will display some excess data instead.
  #config.ssh.pty = true

  config.vm.provision :shell do |sh|
    sh.path = "provision.sh"
    sh.args = "./ansible devops/server.yml devops/hosts"
    sh.keep_color = true
  end
end
