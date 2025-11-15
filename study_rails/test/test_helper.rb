# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def generate_token(user_id)
      payload = { user_id: user_id, exp: 24.hours.from_now.to_i }
      JWT.encode(payload, Rails.application.config.jwt_secret, "HS256")
    end
  end
end
