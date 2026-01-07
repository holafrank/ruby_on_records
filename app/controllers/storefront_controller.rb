class StorefrontController < ApplicationController
  # skip_before_action :require_login

  # GET /
  def index
    @disks = Disk.new_arrivals(10)
    @disks_outlet = Disk.outlet(10)
    @disks_top_sold = Disk.top_sold(10)
  end
end
