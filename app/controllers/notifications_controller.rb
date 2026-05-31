class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent.includes(:actor, :notifiable).limit(50)
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_read!
    head :ok
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
