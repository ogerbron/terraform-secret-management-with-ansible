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

output "mysecret" {
    # The value of the secret is stored in result.mysecret
    value = "${data.external.mysecret.result.mysecret}"
}