# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StudyRails
  class Application < Rails::Application
    config.load_defaults(7.1)
    config.autoload_lib(ignore: ["assets", "tasks"])
    config.api_only = true
    config.jwt_secret = Rails.application.credentials.secret_key_base || "secret"
    config.i18n.default_locale = :ko
  end
end
