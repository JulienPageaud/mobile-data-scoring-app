require 'rails_helper'

feature 'User Edit Page', js: false do
  let(:user) { FactoryGirl.create(:user) }

  before do
    login_as(user, :scope => :user)
    visit "/users/#{user.id}/edit"
  end

  it 'can be reached' do
    expect(page.status_code).to eq(200)
  end

  it 'has an e-mail field' do
    expect(page).to have_field('user_email', type: 'email')
  end

  it 'has a title field' do
    expect(page).to have_field('user[title]')
  end

  it 'has a first name field' do
    expect(page).to have_field('user_first_name', type: 'text')
  end

  it 'has a last name field' do
    expect(page).to have_field('user_last_name', type: 'text')
  end

  it 'has an address field' do
    expect(page).to have_field('user_address', type: 'text')
  end

  it 'has a city field' do
    expect(page).to have_field('user_city', type: 'text')
  end

  it 'has a postcode field' do
    expect(page).to have_field('user_postcode', type: 'text')
  end

  it 'has an employment field' do
    expect(page).to have_field('user_employment', type: 'text')
  end

  it 'has a date of birth field' do
    expect(page).to have_field('user_date_of_birth', type: 'text')
  end

  it 'has a photo ID upload field' do
    expect(page).to have_field('user_photo_id', type: 'file')
  end

  scenario 'user who fills in and submits all their details is eligible to apply for a loan' do
    user_fills_in_details
    user_uploads_photo_id
    click_on 'Save'
    expect(page).to have_content('Ask for a loan')
  end

  scenario 'form is re-rendered if a required field is left blank (e.g. DoB)' do
    user_forgets_date_of_birth
    click_on 'Save'
    expect(page).to have_content('Please enter your date of birth')
  end

  scenario 'user has not uploaded a photo ID' do
    user_fills_in_details
    click_on 'Save'
    expect(page).to have_content('Details incomplete')
  end

  private

  def user_fills_in_details
    choose('Mr')
    fill_in 'user_first_name', with: 'John'
    fill_in 'user_last_name', with: 'Smith'
    fill_in 'user_address', with: 'New Street'
    fill_in 'user_city', with: 'Johannesburg'
    fill_in 'user_postcode', with: '23142'
    fill_in 'user_employment', with: 'banker'
    fill_in 'user_date_of_birth', with: '31/07/1980'
  end

  def user_uploads_photo_id
    attach_file 'user_photo_id', 'public/lewagonsnap.jpg'
  end

  def user_forgets_date_of_birth
    choose('Mr')
    fill_in 'user_first_name', with: 'John'
    fill_in 'user_last_name', with: 'Smith'
    fill_in 'user_address', with: 'New Street'
    fill_in 'user_city', with: 'Johannesburg'
    fill_in 'user_postcode', with: '23142'
    fill_in 'user_employment', with: 'banker'
  end
end
