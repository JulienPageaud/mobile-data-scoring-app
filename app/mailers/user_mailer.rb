class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def email_has_changed(user)
    if DateTime.now < DateTime.now.noon
      @greeting = "Good morning"
    elsif DateTime.now.hour < 18
      @greeting = "Good afternoon"
    else
      @greeting = "Good evening"
    end
    @user = user
    mail to: @user.email
  end
end
