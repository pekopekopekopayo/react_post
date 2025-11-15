# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    @user = User.create!(create_params)
  end

  private

  def create_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
