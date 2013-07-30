default.play_perl.twitter.consumer_key = "IRUAzmA5AjwBTrPQWrCzIQ"
default.play_perl.twitter.consumer_secret = "Cj4hB54BLMYeoG9eEX4fd5gexg02nQLIRJ2S3f0nAH4"
default.play_perl.hostport = 'questhub.io'
default.play_perl.service_name = 'Questhub.io'
default.play_perl.unsubscribe_salt = '1234567890'
default.play_perl.mixpanel_token = '1234567890'

include_attribute 'nodejs'
normal['nodejs']['install_method'] = 'package'
normal['nodejs']['version'] = '0.10.12'
normal['nodejs']['npm'] = '1.3.1'
normal['npm']['version'] = '1.3.1'
