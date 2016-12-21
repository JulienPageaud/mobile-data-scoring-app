require 'rails_helper'

feature "BankDashboards" do
  let(:bank_user) { FactoryGirl.create(:bank_user)}

  # before do
  #   login_as(bank_user, :scope => :bank_user)
  # end

  scenario "bank user can log in to the dashboard", :skip_before do
    visit '/bank_users/sign_in'
    expect(page).to have_field('bank_user[email]')
    expect(page).to have_field('bank_user[password]')

    fill_in 'bank_user[email]', with: "fnbemployee@firstnational.com"
    fill_in 'bank_user[password]', with: "ilovemoney"
    click_on 'Log in'
    save_and_open_screenshot
    expect(current_url.include?('/loans')).to eql(true)
  end


  scenario "bank user can accept a loan application"

  scenario "bank user can decline a loan application"

  scenario "bank user can view outstanding loan details"

  scenario "bank user can view the portfolio tab"

end

