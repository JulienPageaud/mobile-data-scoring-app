class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]
  skip_before_action :authenticate_bank_user!, only: [ :home ]

  def home
  end

  def about
  end

  def legal
  end

  def contact
  end
end
