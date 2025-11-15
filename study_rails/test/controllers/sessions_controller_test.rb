# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.config.jwt_secret = "test_secret"
  end

  test "should create session with valid credentials" do
    user = create(:user, email: "test@example.com", password: "password123")

    post me_sessions_url, params: { email: "test@example.com", password: "password123" }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["token"].present?

    decoded_token = JWT.decode(json_response["token"], "test_secret", true, { algorithm: "HS256" })[0]
    assert_equal user.id, decoded_token["user_id"]
  end

  test "should not create session with invalid email" do
    create(:user, email: "test@example.com", password: "password123")

    post me_sessions_url, params: { email: "wrong@example.com", password: "password123" }, as: :json

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should not create session with invalid password" do
    create(:user, email: "test@example.com", password: "password123")

    post me_sessions_url, params: { email: "test@example.com", password: "wrongpassword" }, as: :json

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should not create session without email" do
    post me_sessions_url, params: { password: "password123" }, as: :json

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should not create session without password" do
    create(:user, email: "test@example.com", password: "password123")

    post me_sessions_url, params: { email: "test@example.com" }, as: :json

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end
end
