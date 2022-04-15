# Make form_with not create remote forms by default, since Turbo doesn't understand them and they break.
Rails.application.config.action_view.form_with_generates_remote_forms = false