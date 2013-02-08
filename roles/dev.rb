name "dev"
description "dev configuration"
override_attributes(
    :dev => true,
    :play_perl => {
        :hostport => 'localhost:3000'
    }
)
