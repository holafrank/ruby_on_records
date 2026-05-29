class Backstore::ReportsController < ApplicationController
  before_action :authorize_user
  before_action :set_sales

  def index
  end

  def metrics
  end

  def analysis
  end


  private

  def set_sales
    @sales = Sale.valid_sales
  end

  def authorize_user
    authorize! :read, Sale
  end
end
