# Requirements
* Hardware
  * 2GB free RAM
  * 30GB free disk space
* Software
  * Vagrant
  * Packer
  * Oracle VirtualBox or Hyper-V
* ~ 30 minutes to run tests

# Usage
Create a box (virtual machine image):

```
packer build win2016-sys.json
vagrant box add win2016-sys-virtualbox.box --force --name win2016-sys
vagrant box add win2016-sys-hyperv.box --force --name win2016-sys
rm win2016-sys-virtualbox.box
rm win2016-sys-hyperv.box
```


Spin up a virtual machine from the box:

`vagrant up`

# Verification
Verify the virtual machine is up and running:

`vagrant powershell`

then
```
whoami
ipconfig
exit
```

# Cleaning up
Remove the virtuatl machine:

`vagrant destroy`


Remove:

```
vagrant box remove win2016-sys
```

Consider also removing downloaded ISO files:

`rm packer_cache/*`


# Rebuilding
```
vagrant destroy --force
vagrant box remove win2016-sys
rm win2016-sys-virtualbox.box
rm win2016-sys-hyperv.box
packer build win2016-sys.json
vagrant box add win2016-sys-virtualbox.box --force --name win2016-sys
vagrant box add win2016-sys-hyperv.box --force --name win2016-sys
vagrant up
```
