require 'rails_helper'

feature "Apply For A Loan" do
  let(:user) { FactoryGirl.create(:user, :with_details, :details_complete) }

  scenario "user with details completed can apply for a loan" do
    FactoryGirl.create(:bank)

    login_as(user, :scope => :user)
    visit "/users/#{user.id}"

    click_on 'Ask for a loan'
    expect(page).to have_field('loan[requested_amount]')
    expect(page).to have_field('loan[category]')
    expect(page).to have_field('loan[purpose]')
    expect(page).to have_field('loan[description]')
    fill_in 'loan[requested_amount]', with: 1000.00
    choose 'loan_category_personal'
    select('Medical Expenses', from: 'personal-dropdown')
    fill_in 'loan[description]', with: 'I would like to pay for an operation'
    click_on 'Submit'
    expect(page).to have_content('Application Pending')
  end

  scenario "user with incomplete details cannot apply yet" do
    user.update(details_completed: false)
    login_as(user, :scope => :user)
    visit "/users/#{user.id}"

    expect(page).to_not have_content('Ask for a loan')
    click_on 'Edit your details'
    expect(current_url.include?('/edit')).to eql(true)
  end
end
