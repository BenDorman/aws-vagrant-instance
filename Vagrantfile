# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require the AWS provider plugin and YAML module
require 'vagrant-aws'
require 'yaml'

# Read YAML file with instance information
instances = YAML.load_file(File.join(File.dirname(__FILE__), 'instances.yml'))

# Specify Vagrant version and Vagrant API version
Vagrant.require_version '>= 1.6.0'
VAGRANTFILE_API_VERSION = '2'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'aws'

# Create and configure the AWS instance(s)
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Use dummy AWS box
  config.vm.box = 'aws-source'

  # Specify AWS authentication information
  config.vm.provider 'aws' do |aws, override|
    # Specify access/authentication information, keypair
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = instances['keypair_name']
    aws.iam_instance_profile_arn = instances['iam_role']

    # Specify region and AMI ID
    aws.region = instances['region']
    aws.ami = instances['ami']
    aws.security_groups = instances['security_groups']
    aws.instance_type = instances['instance_type']
    aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => instances['size'] }]

	aws.tags = {
		'Name' => 'GUI-RHEL73',
		'Toolset' => 'RDP Git Docker k8s'
		}     

	#provisioning script. This is where we add all the software to be available at boot time.
	config.vm.provision :shell, path: "bootstrap.sh"
    # Specify username and private key path
    override.ssh.username = instances['user']
    override.ssh.private_key_path =instances['private_key_path']



  end # config.vm.provider 'aws'
end # Vagrant.configure
