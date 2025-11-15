# frozen_string_literal: true

class CustomError < StandardError
  attr_accessor :status

  def initialize(status)
    path_names = self.class.name.split("::")
    error_class_name = path_names.last.underscore
    error_parent_name = path_names[-2].underscore

    @status = status
    super(I18n.t("controllers.#{error_parent_name}.errors.#{error_class_name}"))
  end
end

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from CustomError, with: :render_custom_error_response

  attr_reader :current_user

  def authenticate_user
    header = request.headers["Authorization"]
    return unless header

    token = header.split(" ").last
    decoded = JWT.decode(token, Rails.application.config.jwt_secret, true, { algorithm: "HS256" })[0]
    @current_user = User.find(decoded["user_id"])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    nil
  end

  def authenticate_user!
    raise AuthenticationError if authenticate_user.nil?

    @current_user
  end

  private

  def render_unprocessable_entity_response(e)
    render(json: { errors: e.record.errors.full_messages }, status: :unprocessable_content)
  end

  def render_custom_error_response(e)
    render(json: { error: e.message }, status: e.status)
  end

  class AuthenticationError < CustomError
    def initialize
      super(401)
    end
  end
end
