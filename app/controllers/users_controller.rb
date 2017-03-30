class UsersController < ApplicationController
  # ... edited by app gen (Devise users controller)
  before_action :authenticate_user!

  def show
    # ... edited by app gen (Devise users controller)
    @current_user = current_user
  end

  def index
  end
end
