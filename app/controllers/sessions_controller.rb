class SessionsController < ApplicationController
  def new
    # Render the login form
  end

  def create
    response = Faraday.post("#{ENV['API_BASE_URL']}/users/sign_in") do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = { user: { email: params[:email], password: params[:password] } }.to_json
    end

    if response.status == 200
      user_data = JSON.parse(response.body)
      session[:jwt_token] = user_data["token"]
      redirect_to root_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    session[:jwt_token] = nil
    redirect_to login_path, notice: "Logged out successfully!"
  end
end