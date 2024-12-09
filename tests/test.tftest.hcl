run "testing" {
  command = plan
  module {
    source = "./tests/setup"
  }
  //assertion to check if the plan ran succesfully for the ASE
  assert {
    condition     = module.test.web_server_farm_sku == "I1v2"
    error_message = "The SKU of the web server farm is not I1v2"
  }
}