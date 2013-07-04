define [
    "backbone", "jquery"
], (Backbone, $) ->
    class extends Backbone.Model
        url: "/api/current_user/settings"

        generateApiToken: ->
            $.post("/api/current_user/generate_api_token")
                .done (data) =>
                    @set "api_token", data.api_token
