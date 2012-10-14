apt_repo "medibuntu" do
  key_id "0C5A2783"
  keyserver "keyserver.ubuntu.com"
  key_package "medibuntu-keyring"
  url "http://packages.medibuntu.org/"
  components ["free", "non-free"]
end
