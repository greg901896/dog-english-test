class Admin::BaseController < ApplicationController
  before_action :require_admin!

  private

  def require_admin!
    return if current_user&.admin?

    redirect_to authenticated_root_path, alert: "你沒有權限進入後台"
  end
end
