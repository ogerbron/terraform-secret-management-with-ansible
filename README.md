# terraform-secret-management-with-ansible

A quick example of how to handle Terraform secret in your repository by using Ansible Vault encryption feature.

Here is the use case:

1. You already use Ansible and its vault feature to manager your secrets in some git repository, or to encrypt sensitive information
2. You also use Terraform as your Infrastructure as code tool, and you start having secret to manage.
3. You don't have any system for secret management (i.e. something like [vault](https://www.vaultproject.io/))

Since you share your terraform code accross your team, you also have to share the secret. Therefore you either:

- Store your secrets somewhere else (never in clear text in your git repository!!), and you have to manually enter the secret when execution terraform. No need to say this is not the best for automation.
- Store your secrets nevertheless in clear text in your git repository (what did I say about that!?).
- Use an external tools to encrypt your secrets, in this case we will be using [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)

## How to

*Requirements*:

- ansible
- jq
- terraform

To run this example, simply move to the folder `terraform-example`, and run:

```bash
cd terraform-example
export ANSIBLE_VAULT_PASSWORD_FILE=$(pwd)/../.ansible_vault_file
terraform init
terraform apply
```

The `terraform apply` command should output the following:

```bash
$> terraform apply
data.external.mysecret: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

mysecret = i_am_batman
```

## How to use it yourself

This example has three main components:

- The bash script we use to extract the vaulted secret, located in the folder `_tools`
- The file containing the secret, located in the folder `_secrets`
- The terraform data block to call the script and set it in a terraform resource:

```bash
data "external" "mysecret" {
  # Call the script to run the `ansible -m debug` command
  program = ["bash", "../_tools/get_ansible_secret.sh"]

  query = {
    # Set the output in this key
    var = "mysecret"
    # The file containing the secret we want to decrypt
    file = "../_secrets/secrets.yml"
  }
}
```

You can use the value as any other terraform resource with:

```bash
${data.external.mysecret.result.mysecret}
```

TODO: explain the whole thing.
