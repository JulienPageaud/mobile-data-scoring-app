class UserMailer < ApplicationMailer
  before_action :set_greeting
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def email_has_changed(user)
    @user = user
    mail to: @user.email
  end

  def application_sent_confirmation(arguments)
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
