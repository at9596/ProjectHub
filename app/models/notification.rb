class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

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
end
