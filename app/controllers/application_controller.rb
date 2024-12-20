class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def authenticate_user!
    # Skip authentication for the login page
    return if request.path == login_path

    # Redirect to login if no token is present
    unless session[:jwt_token]
      redirect_to login_path, alert: "You need to log in to access this page."
    end
  end

  def current_user_token
    session[:jwt_token]
  end

  def api_request(&block)
    response = block.call
    if response.status == 401
      session[:jwt_token] = nil
      redirect_to login_path, alert: "Session expired. Please log in again."
    else
      response
    end
  end
end
