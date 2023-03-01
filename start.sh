#!/bin/bash
terraform apply --auto-approve
cd ansible
ansible -m ping all
ansible-playbook playbook_send_conf.yml
