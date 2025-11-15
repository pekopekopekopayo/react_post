# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :authenticate_user!, only: [:me]

  def create
    user = User.find_by(email: params[:email])

    raise AuthenticationError if user.nil? || !user.authenticate(params[:password])

    render(json: { token: encode_token(user.id) })
  end

  def me
    @user = current_user
  end

  private

  def encode_token(user_id)
    payload = { user_id: user_id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, Rails.application.config.jwt_secret, "HS256")
  end

  class AuthenticationError < CustomError
    def initialize
      super(401)
    end
  end
end
