# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.config.jwt_secret = "test_secret"
  end

  test "should create session with valid credentials" do
    user = create(:user, email: "test@example.com", password: "password123")

    post sessions_url, params: { email: "test@example.com", password: "password123" }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["token"].present?

    decoded_token = JWT.decode(json_response["token"], "test_secret", true, { algorithm: "HS256" })[0]
    assert_equal user.id, decoded_token["user_id"]
  end

  test "should not create session with invalid email" do
    create(:user, email: "test@example.com", password: "password123")

    post sessions_url, params: { email: "wrong@example.com", password: "password123" }, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should not create session with invalid password" do
    create(:user, email: "test@example.com", password: "password123")

    post sessions_url, params: { email: "test@example.com", password: "wrongpassword" }, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should not create session without email" do
    post sessions_url, params: { password: "password123" }, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should not create session without password" do
    create(:user, email: "test@example.com", password: "password123")

    post sessions_url, params: { email: "test@example.com" }, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should get current user with valid token" do
    user = create(:user)
    token = generate_token(user.id)

    get me_sessions_url, headers: { "Authorization" => "Bearer #{token}" }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal user.id, json_response["id"]
    assert_equal user.name, json_response["name"]
    assert_equal user.email, json_response["email"]
  end

  test "should not get current user without token" do
    get me_sessions_url, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should not get current user with invalid token" do
    get me_sessions_url, headers: { "Authorization" => "Bearer invalid_token" }, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  private

  def generate_token(user_id)
    payload = { user_id: user_id, exp: 24.hours.from_now.to_i }
    secret = Rails.application.config.jwt_secret || "test_secret"
    JWT.encode(payload, secret, "HS256")
  end
end
