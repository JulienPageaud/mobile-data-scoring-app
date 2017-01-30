require 'rails_helper'

feature 'Password reset' do
  before do
    ActionMailer::Base.deliveries = []
    visit root_path
    page.find('.glyphicon-user').click
    click_on('Sign in')
    click_on('Forgot your password?')
    expect(page).to have_content('Email or mobile number')
  end

  it 'can be reached' do
    expect(page.status_code).to eq(200)
  end

  scenario 'visitor cannot reset his password if account is inexistant' do
    user_can_enter_reset_information_and_submit('unknown@email.com')
    expect(ActionMailer::Base.deliveries.count).to eq(0)
  end

  scenario 'visitor can reset his password through email' do
    user = FactoryGirl.create(:user, :with_email, :with_details)
    user_can_enter_reset_information_and_submit(user.email)
    expect(ActionMailer::Base.deliveries.count).to eq(1)
    link = ActionMailer::Base.deliveries.last.body.raw_source.match(/href="(?<url>.+?)">/)[:url]
    visit link.gsub('http://test.yourhost.com', '')

    expect(current_path).to eq('/users/password/edit')
    expect(page).to have_content('Change your password')

    fill_in 'user[password]', with: 'dadada'
    fill_in 'user[password_confirmation]', with: 'dadadas'
    click_on 'Change my password'

    expect(page).to have_content('doesn\'t match Password')
    fill_in 'user[password]', with: 'dadada'
    fill_in 'user[password_confirmation]', with: 'dadada'
    click_on 'Change my password'

    expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
    expect(current_path).to eq(user_path(user))
  end

  scenario 'visitor can reset his password through SMS' do
    user = FactoryGirl.create(:user)
    user_can_enter_reset_information_and_submit(user.mobile_number)
    expect(ActionMailer::Base.deliveries.count).to eq(0)

    # link = ActionMailer::Base.deliveries.last.body.raw_source.match(/href="(?<url>.+?)">/)[:url]
    # visit link.gsub('http://test.yourhost.com', '')

    # expect(current_path).to eq('/users/password/edit')
    # expect(page).to have_content('Change your password')

    # fill_in 'user[password]', with: 'dadada'
    # fill_in 'user[password_confirmation]', with: 'dadadas'
    # click_on 'Change my password'

    # expect(page).to have_content('doesn\'t match Password')
    # fill_in 'user[password]', with: 'dadada'
    # fill_in 'user[password_confirmation]', with: 'dadada'
    # click_on 'Change my password'

    # expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
    # expect(current_path).to eq(user_path(user))
  end

  private

  def user_can_enter_reset_information_and_submit(email)
    expect(current_path).to eq('/users/password/new')
    fill_in 'user[email]', with: email
    click_on "Send me reset password instructions"
    expect(current_path).to eq('/users/sign_in')
    expect(page).to have_content('If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.')
  end
end
