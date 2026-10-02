# Greffondor

Ansible playbooks to configure a Raspberry Pi to be used as an implant for physical intrusion during Red Team operations. 

ansible-galaxy collection install community.docker --force
ansible-playbook setup-greffondor.yml --ask-vault-pass -e @secrets.yml
