class StorefrontController < ApplicationController
  # skip_before_action :require_login

  # GET /
  def index
    @disks = Disk.order(created_at: :desc)
    @disks_outlet = Disk.where("stock < ?", 10 ) #   @disks_outlet = Disk.order(stock: :desc).limit(10)
    @disks_top_sold = Disk.top_sold(10)
  end
end
