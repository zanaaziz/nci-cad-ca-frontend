class SessionsController < ApplicationController
  def new
    # 
  end

  # Handles user login
  def create
    # Sends a POST request to the backend API for authentication
    response = Faraday.post("#{ENV['API_BASE_URL']}/users/sign_in") do |req|
      req.headers["Content-Type"] = "application/json" # Set content type as JSON
      req.body = { user: { email: params[:email], password: params[:password] } }.to_json # Pass login credentials
    end

    if response.status == 200
      # Parse the API response to extract the JWT token
      user_data = JSON.parse(response.body)
      session[:jwt_token] = user_data["token"] # Store the JWT token in the session

      # Redirect to the home page on successful login
      redirect_to root_path, notice: "Logged in successfully!"
    else
      # Show an error message and re-render the login page for invalid credentials
      flash.now[:alert] = "Invalid email or password"
      render :new
    end
  end

  # Handles user logout
  def destroy
    session[:jwt_token] = nil # Clear the session token
    redirect_to login_path, notice: "Logged out successfully!" # Redirect to login page
  end
end