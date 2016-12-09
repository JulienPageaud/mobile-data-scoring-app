ActionMailer::Base.smtp_settings = {
  address: "mail.gandi.net",
  port: 587,
  domain: 'strideworld.com',
  user_name: ENV['GANDI_LOGIN'],
  password: ENV['GANDI_PASSWORD'],
  authentication: :login,
  enable_starttls_auto: true
}
