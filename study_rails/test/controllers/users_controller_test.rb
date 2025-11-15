# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should create user with valid params" do
    user_params = { user: attributes_for(:user) }

    assert_difference("User.count", 1) do
      post users_url, params: user_params, as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal user_params[:user][:name], json_response["name"]
    assert_equal user_params[:user][:email], json_response["email"]
    assert json_response["id"].present?
    assert json_response["created_at"].present?
    assert json_response["updated_at"].present?
    refute json_response.key?("password_digest")
  end

  test "should not create user without name" do
    user_params = { user: attributes_for(:user, name: nil) }

    assert_no_difference("User.count") do
      post users_url, params: user_params, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Name can't be blank"
  end

  test "should not create user without email" do
    user_params = { user: attributes_for(:user, email: nil) }

    assert_no_difference("User.count") do
      post users_url, params: user_params, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Email can't be blank"
  end

  test "should not create user with invalid email format" do
    user_params = { user: attributes_for(:user, email: "invalid_email") }

    assert_no_difference("User.count") do
      post users_url, params: user_params, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body["errors"].any? { |error| error.include?("Email") }
  end

  test "should not create user with duplicate name" do
    create(:user, name: "existing_user", email: "existing@example.com")

    user_params = { user: attributes_for(:user, name: "existing_user", email: "new@example.com") }

    assert_no_difference("User.count") do
      post users_url, params: user_params, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Name has already been taken"
  end

  test "should not create user with duplicate email" do
    create(:user, name: "user1", email: "existing@example.com")

    user_params = { user: { name: "user2", email: "existing@example.com" } }

    assert_no_difference("User.count") do
      post users_url, params: user_params, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Email has already been taken"
  end

  test "should not create user with short password" do
    user_params = { user: attributes_for(:user, password: "short", password_confirmation: "short") }

    assert_no_difference("User.count") do
      post users_url, params: user_params, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body["errors"].any? { |error| error.include?("Password") }
  end

  test "should not create user with mismatched password confirmation" do
    user_params = {
      user: attributes_for(:user, password: "password123", password_confirmation: "different123"),
    }

    assert_no_difference("User.count") do
      post users_url, params: user_params, as: :json
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body["errors"].any? { |error| error.include?("Password confirmation") }
  end
end
