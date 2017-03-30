class OtherPagesController < ApplicationController
  def map
  end

  def email_form
  end

  def email_send
  end

  def under_construction
    # ... edited by app gen (other pages)
    @message = params.permit(:message)[:message]
  end
end
