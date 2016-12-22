require 'rails_helper'

feature "BankDashboards" do
  subject { FactoryGirl.create(:bank_user)}

  scenario "bank user can log in to the dashboard", :skip_before do
    visit '/bank_users/sign_in'

    expect(page).to have_field('bank_user[email]')
    expect(page).to have_field('bank_user[password]')

    fill_in 'bank_user[email]', with: "fnbemployee@firstnational.com"
    fill_in 'bank_user[password]', with: "ilovemoney"
    click_on 'Log in'
    expect(page.status_code).to eq(200)
  end


  scenario "bank user can accept a loan application" do
    application = FactoryGirl.build(:loan, :pending_application, bank: subject.bank)
    # this is done to avoid after(:create) statements
    application.save

    login_as(subject, :scope => :bank_user)
    visit "bank_users/#{subject.id}/loans"

    find('.loan-link').click
    application.update(start_date: DateTime.now,
      final_date: DateTime.now + application.duration_months.month)
    click_on 'Accept'
    expect(page.status_code).to eq(200)
  end

  scenario "bank user can decline a loan application" do
    application = FactoryGirl.build(:loan, :pending_application, bank: subject.bank)
    # this is done to avoid after(:create) statements
    application.save

    login_as(subject, :scope => :bank_user)
    visit "bank_users/#{subject.id}/loans"

    find('.loan-link').click
    find('.decline-trigger').click
    fill_in 'loan[decline_reason]', with: "Credit score too low"
    click_on 'Decline Application'
    expect(page.status_code).to eq(200)
  end

  scenario "bank user can view outstanding loan details" do
    login_as(subject, :scope => :bank_user)
    visit "bank_users/#{subject.id}/loans"

    find('#outstanding-tab').trigger('click')
    expect(page.status_code).to eq(200)
    expect(page).to have_css('.spinner')
    expect(page).not_to have_css('.spinner')
    expect(page).to have_content('Loans - Good Book')
  end

  scenario "bank user can view the portfolio tab" do
    login_as(subject, :scope => :bank_user)
    visit "bank_users/#{subject.id}/loans"

    find('#portfolio-tab').trigger('click')
    expect(page.status_code).to eq(200)
    expect(page).to have_css('.spinner')
    expect(page).not_to have_css('.spinner', wait: 10)
    expect(page).to have_css('.data-graph')
  end

end

