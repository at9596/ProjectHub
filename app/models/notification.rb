class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit :broadcast_to_recipient

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  def message
    case action
    when "mentioned"  then "#{actor.name || actor.email} mentioned you in a comment"
    when "assigned"   then "#{actor.name || actor.email} assigned you a task"
    when "commented"  then "#{actor.name || actor.email} commented on a task"
    when "invited"    then "#{actor.name || actor.email} invited you to the workspace"
    else "#{actor.name || actor.email} #{action}"
    end
  end

  private

  def broadcast_to_recipient
    broadcast_prepend_to(
      "notifications_user_#{user.id}",
      target: "notifications-list",
      partial: "notifications/notification",
      locals: { notification: self }
    )

    broadcast_replace_to(
      "notifications_user_#{user.id}",
      target: "notification-badge",
      partial: "notifications/badge",
      locals: { badge_user: user }
    )

    broadcast_append_to(
      "notifications_user_#{user.id}",
      target: "notification-toasts",
      partial: "notifications/toast",
      locals: { notification: self }
    )
  end
end
