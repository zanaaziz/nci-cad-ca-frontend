class ApplicationController < ActionController::Base
  # Authenticate the user before any action is performed
  before_action :authenticate_user!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  # Authenticate the user
  #
  # Skips authentication for the login page and checks if a JWT token exists in the session.
  # Redirects to the login page with an alert if authentication fails.
  def authenticate_user!
    # Skip authentication for the login page
    return if request.path == login_path

    # Redirect to login if no token is present
    unless session[:jwt_token]
      redirect_to login_path, alert: "You need to log in to access this page."
    end
  end

  # Retrieve the current user's JWT token
  #
  # @return [String, nil] The JWT token stored in the session
  def current_user_token
    session[:jwt_token]
  end
end