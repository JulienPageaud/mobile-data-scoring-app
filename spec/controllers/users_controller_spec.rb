require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #show' do
    let!(:user) { FactoryGirl.create(:user) }
    subject { user }

    it 'has a 200 status code' do
      get user_url(subject)
      assert_response :success
    end

    it 'renders the :show view'
  end

  describe 'GET #edit' do
    let!(:user) { FactoryGirl.create(:user) }
    subject { user }

    it 'assigns the current user to @user' do
      get edit_user_url(subject)
      expect(response).to be_success
    end

    it 'has a 200 status code'

    it 'renders the :edit view'
  end

  describe 'POST #update' do
    context 'with valid attributes' do
      it 'assigns the current user to @user'

      it 'updates the user in the database'

      it 'it sends an email if the user\'s email has been updated'

      it 'redirects to the user\'s profile page'
    end

    context 'with invalid attributes' do
      it 'does not update the user in the database'

      it 're-renders the :edit template'
    end
  end
end
