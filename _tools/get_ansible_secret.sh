#!/bin/bash

for program in ansible jq
do
  command -v $program >/dev/null 2>&1
  if [ $? -ne 0 ]
  then
    echo "Cannot find command ${program}"
  fi
done

# Exit if any of the intermediate steps fail
set -e

# Set your encrypted variable in a yml file:
# encrypted_var: !vault |
#         $ANSIBLE_VAULT;1.1;AES256
#         34085318063186031860318603186031
#         ...
#
# In terraform, use:
# data "external" "encrypted_var" {
#  program = ["bash", "/PATH/TO/_tools/get_ansible_secret.sh"]
#
#  query = {
#    var = "encrypted_var"
#    file = "file_containing_encrypted_vars.yml"
#  }
#}
#
# You can then use the var with
# ${data.external.encrypted_var.result.encrypted_var}

# Extract "file" and "var" arguments from the input into
# FILE and VAR shell variables.
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
eval "$(jq -r '@sh "FILE=\(.file) VAR=\(.var)"')"

# You need to have your env var ANSIBLE_VAULT_PASSWORD_FILE set to avoid asking
# for the vault password
ansible localhost -m debug -a var=${VAR} -e @${FILE} 2> /dev/null | sed 's/localhost | .* => \(.*\)/\1/' | jq .
