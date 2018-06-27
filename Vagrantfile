#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# vi: set ft=ruby :

require 'etc'
require 'shellwords'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "bento/centos-7.4"
  config.vm.hostname = File.expand_path(File.dirname(__FILE__)).split('/')[-1]

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", type: "dhcp"

  # Tweak the VMs configuration.
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = Etc.nprocessors
    vb.memory = 1024
    vb.linked_clone = true
  end

  # share the ~/.config/gcloud directory to grant access to the credentials to the VM
  # NOTE: since Google insists on having a file rather than (like AWS) using environment variables, there is no better
  # way of doing this at the moment.
  config.vm.synced_folder File.join(ENV.fetch('HOME'), ".config", 'gcloud'), "/home/vagrant/.config/gcloud", create: true

  # Configure the VM using Ansible
  config.vm.provision "ansible_local" do |ansible|
    ansible.galaxy_role_file = "requirements.yml"
    ansible.galaxy_roles_path = ".ansible/galaxy-roles"
    ansible.provisioning_path = "/vagrant"
    ansible.playbook = "vagrant.yml"
    # allow passing ansible args from environment variable
    ansible.raw_arguments = Shellwords::shellwords(ENV.fetch("ANSIBLE_ARGS", ""))
  end
end
