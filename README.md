# Greffondor

Ansible playbooks to configure a Raspberry Pi to be used as a dropbox for physical intrusion during Red Team operations. 

## Requirements

To start, you will need:

- A fresh raspbian installed on a raspberry (tested on Model 4 B), with a least 120GB of storage if you want to use big exegol image.
- A user with SSH key-based access (by default, "supervisor" is used, see `inventory/hosts.yml.example`)
- Ansible and community.docker collection installed (`ansible-galaxy collection install community.docker --force`) 


## Configuration

Many parameters could be defined using the `inventory/hosts.yml` file.
An example file is provided (`inventory/hosts.yml.example`) with some predefined variables.
However, you will need to complete:

- `ansible_host`: Then IP assigned to your raspberry.
- `ansible_ssh_private_key_file`: Path to private key which allows you to connect to the raspberry.
- `wg_server_ip`: The wireguard VPN server IP you want to use.
- `wg_server_pubkey`: The wireguard VPN server public key.

You can also configure the following, but it is optional:

- `ansible_user`: The user used for SSH connection. (Default: supervisor)
- `ansible_python_interpreter`: The path to the Python interpreter on the remote machine. (Default: /usr/bin/python3)
- `ansible_ssh_common_args`: Additional SSH arguments for the connection. (Default: "-o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new")
- `is_dev`: Indicates if the environment is in development mode. See detailed steps for the usage (Default: true)
- `wg_server_port`: The port used by the WireGuard server. (Default: 51820)
- `wg_client_ip`: The IP address assigned to the WireGuard client. (Default: 10.0.0.2/32)
- `pi_hostname`: The hostname to be set on the Raspberry Pi. (Default: DEV-INFRA-004)
- `mac_address`: The MAC address to be set on the device for LAN interface. (Default: 10:C5:95:32:de:22)
- `restricted_user`: The name of the restricted user to be created. (Default: technician)
- `restricted_shell`: The shell assigned to the restricted user. (Default: /bin/bash)
- `restricted_groups`: The groups the restricted user belongs to. (Default: sudo)
- `luks_size`: The size of the LUKS partition in GB. (Default: 20)
- `start_NetAlertX_on_provision`: Whether to start NetAlertX during provisioning. (Default: false)
- `install_image`: Whether to install the exegol image. It can take a lot of time (Default: true)


Then, create users password in a vault:

```bash
ansible-vault create secrets.yml
```

With content:

```yaml
become_password_low: "XXXXXXXX" # password for restricted user (not the one used for ssh connection)
become_password_root: "XXXXXXXX" # password for root
wg_private_key: "XXXXXXXXX" # wireguard private key for pi
wg_preshared_key: "XXXXXXXXXXXX" # shared secret with wireguard server 
```

## Usage

Run the playbook by specifying the vault:

```bash
ansible-playbook setup-greffondor.yml --ask-vault-pass -e @secrets.yml
```

## Testing

Run the playbook by specifying the vault:

```bash
ansible-playbook test-greffondor.yml --ask-vault-pass -e @secrets.yml
```

## Detailed steps

The setup playbook will:

- Change root password to the one defined.
- Update repo and packages.
- Disable wifi, setup 4G, LAN (with new MAC) and wireguard network interfaces.
- Setup script to restart vpn if needed.
- Change hostname.
- Restrict sudo to only restricted user.
- Harden SSH: If dev mode is off, listen only on the WireGuard interface. Restrict direct SSH access for limited users.
- Create a luks container for restricted user home directory, which can be open when logging in with su.
- Create restricted user.
- Install some tools: exegol, a custom logger (including commands output), NetalertX.
- Create offensive scripts to use.
