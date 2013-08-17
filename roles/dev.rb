name "dev"
description "dev configuration"
override_attributes(
    :play_perl => {
        :hostport => 'localhost:3000'
    }
)
run_list "role[common]", "recipe[questhub::dev]", "recipe[phantomjs]"
