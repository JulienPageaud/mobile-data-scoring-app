class UserMailer < ApplicationMailer
  before_action :set_greeting

  def email_has_changed(user)
    @user = user
    mail to: @user.email
  end

  def application_sent_confirmation(arguments)
    @user = arguments[:user]
    @loan = arguments[:loan]
    mail to: @user.email
  end

  def application_reviewed(arguments)
    @user = arguments[:user]
    @loan = arguments[:loan]
    mail to: @user.email
  end

  private

  def set_greeting
    if DateTime.now < DateTime.now.noon
      @greeting = "Good morning"
    elsif DateTime.now.hour < 18
      @greeting = "Good afternoon"
    else
      @greeting = "Good evening"
    end
  end
end
