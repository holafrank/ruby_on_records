class Backstore::ReportsController < ApplicationController
  before_action :authorize_user
  before_action :set_sales

  def index
  end

  def metrics
     @data = {'2026-01-01' => 5, '2026-02-01' => 8, '2026-03-01' => 12, '2026-04-01' => 15, '2026-05-01' => 10, '2026-06-01' => 9}
  end

  def analysis
    @data = {'2026-01-01' => 5, '2026-02-01' => 8, '2026-03-01' => 12, '2026-04-01' => 15, '2026-05-01' => 10, '2026-06-01' => 9}
  end

  private

  def set_sales
    @sales = Sale.valid_sales
  end

  def authorize_user
    authorize! :read, Sale
  end
end
