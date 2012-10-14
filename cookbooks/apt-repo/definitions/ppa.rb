define :ppa,
    :key_id => nil,
    :distribution => nil,
    :source_packages => false,
    :description => nil do

  # ppa name should have the form "user/archive"
  unless params[:name].count('/') == 1
    raise "Invalid PPA name"
  end

  # also accept Launchpad-style ppa names
  ppa = params[:name].gsub(/^ppa:/, '')
  user, archive = ppa.split('/')
  key_id = params[:key_id]

  description = params[:description]
  description = description ? "PPA: #{description}" : "ppa:#{ppa}"
  distribution = params[:distribution]
  source_packages = params[:source_packages]

  unless key_id
    # use the Launchpad API to get the correct archive signing key id
    require 'open-uri'
    base_url = 'https://api.launchpad.net/1.0'
    archive_url = "#{base_url}/~#{user}/+archive/#{archive}"
    key_fingerprint_url = "#{archive_url}/signing_key_fingerprint"
    key_id_long = open(key_fingerprint_url).read.tr('"', '')
    key_id = key_id_long[-8..-1]
  end

  # let the apt_repo definition do the heavy lifting
  apt_repo "#{user}_#{archive}.ppa" do
    url "http://ppa.launchpad.net/#{ppa}/ubuntu"
    key_id key_id
    keyserver "keyserver.ubuntu.com"
    distribution distribution
    source_packages source_packages
    description description
  end
end
