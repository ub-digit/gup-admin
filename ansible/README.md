# Example playbook

## Installation
To install ub-ansible-deploy role required by this playbook run `ansible-galaxy install -r requirements.yml`

## Deployment
- Save vault password in `.vault_password`
- Run `ansible-playbook -i inventory/<host>.yml --vault-password-file .vault_password deploy.yml` replacing \<host\> with host alias name, for example `lab`.

(The -C flag can be used to run the playbook without performing and changes on the target server.)
