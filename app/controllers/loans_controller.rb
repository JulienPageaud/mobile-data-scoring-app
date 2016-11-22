class LoansController < ApplicationController
  skip_before_filter :authenticate_bank_user!

  def index
  end

  def new
  end

  def create

  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  private

  def loan_params
    params.require(:loan).permit(:requested_amount_cents, :category, :purpose, :description)
  end
end
