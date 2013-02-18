class ApplicationController < ActionController::Base
  protect_from_forgery

  def logged_in?
    current_user.present?
  end

  def current_user
    @current_user ||= authenticate_with_http_token do |token, options|
      User.with_token(token)
    end
  end

  def require_user
    return
    unless logged_in?
      respond_to do |format|
        format.json do
          render json: {error: :bad_token}
        end
        format.html do
          store_url
          redirect_to session_auth_url
        end
      end
    end
  end

  def store_location
    session[:stored_url] = request.request_uri
  end

  def return_to_stored_location
    redirect_to session.delete(:stored_url) || home_url
  end
end

