# -*- mode: ruby -*-
# vi: set ft=ruby :

## TODO: Update value with desired configuration and run `vagrant provision`
## Configs located at ansible/templates/inter_node_tls.<config_variant>.config
## Allowed values:
##    cert_both_customize
##    cert_client_only_customize
##    cert_none_customize
##    wildcard_cert_both_customize
##    wildcard_cert_client_only_customize
##    wildcard_cert_none_customize
##
config_variant = "wildcard_cert_both_customize"          # works in erlang25; broken in erlang26
# config_variant = "wildcard_cert_client_only_customize" # working both erlang25 and erlang26

rabbitmq_3_12_version = "3.12.12-1*"
rabbitmq_3_13_version = "3.13.1-1*"
erlang_25_version = "1:25.*" # "1:25.3.2.12-*"
erlang_26_version = "1:26.*" # "1:26.2.5-*"

Vagrant.configure("2") do |config|
  config.vagrant.plugins = [
    "vagrant-vbguest",
    "vagrant-hostmanager",
    "vagrant-timezone",
  ]
  config.ssh.forward_agent = false
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.timezone.value = :host
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 1 * 1024]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--cpus", 2]
    vb.linked_clone = true
  end
  config.vbguest.auto_update = false

  config.vm.define "rmq312_er25" do |rmq|
    rmq.vm.network "private_network", ip: "192.168.56.50", netmask: "255.255.248.0"
    rmq.vm.hostname = "rmq312-er25"
    rmq.hostmanager.aliases = [
      "rmq312-er25.mydomain.local",
    ]
    rmq.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/playbook.yaml"
      ansible.version = "9.1.0"
      ansible.install_mode = "pip"
      ansible.extra_vars = {
        config_variant: config_variant,
        rabbitmq_version: rabbitmq_3_12_version,
        erlang_version: erlang_25_version,
        desired_fqdn_hostname: "rmq312-er25.mydomain.local",
      }
    end
  end
  config.vm.define "rmq312_er26" do |rmq|
    rmq.vm.network "private_network", ip: "192.168.56.51", netmask: "255.255.248.0"
    rmq.vm.hostname = "rmq312-er26.mydomain.local"
    rmq.hostmanager.aliases = [
      "rmq312-er26.mydomain.local",
    ]
    rmq.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/playbook.yaml"
      ansible.version = "9.1.0"
      ansible.install_mode = "pip"
      ansible.extra_vars = {
        config_variant: config_variant,
        rabbitmq_version: rabbitmq_3_12_version,
        erlang_version: erlang_26_version,
        desired_fqdn_hostname: "rmq312-er26.mydomain.local"
      }
    end
  end
  config.vm.define "rmq313_er26" do |rmq|
    rmq.vm.network "private_network", ip: "192.168.56.52", netmask: "255.255.248.0"
    rmq.vm.hostname = "rmq313-er26"
    rmq.hostmanager.aliases = [
      "rmq313-er26.mydomain.local",
    ]
    rmq.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/playbook.yaml"
      ansible.version = "9.1.0"
      ansible.install_mode = "pip"
      ansible.extra_vars = {
        config_variant: config_variant,
        rabbitmq_version: rabbitmq_3_13_version,
        erlang_version: erlang_26_version,
        desired_fqdn_hostname: "rmq313-er26.mydomain.local",
      }
    end
  end
end
