class StorefrontController < ApplicationController
  # skip_before_action :require_login

  # GET /
  def index
    @disks = Disk.new_arrivals(6)
    @disks_outlet = Disk.outlet(6)
    @disks_top_sold = Disk.top_sold(9)
  end
end
