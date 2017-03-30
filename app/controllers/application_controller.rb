class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # ... edited by app gen (Devise), START BLOCK
  # https://stackoverflow.com/questions/15944159/devise-redirect-back-to-the-original-location-after-sign-in-or-sign-up
  # ... This seems to work. I don't know WTF...
  #     https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  after_action :store_location

  before_action :configure_devise_params, if: :devise_controller?

  private

  def store_location
    return if request.fullpath =~ %r{/users}

    session[:previous_url] = request.fullpath
  end

  def after_sign_in_path_for(_resource)
    session[:previous_url] || root_path
  end

  def after_sign_out_path_for(_resource)
    # ... prescribed but doesn't work.
    # session[:previous_url] || root_path
    root_path
  end

  def configure_devise_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  # ... END BLOCK
end
