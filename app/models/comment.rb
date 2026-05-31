class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true

  after_create :parse_mentions

  private

  # Parse @username mentions and create notifications
  def parse_mentions
    mentioned_names = body.scan(/@(\w+)/).flatten.uniq
    return if mentioned_names.empty?

    org = commentable.try(:organization) || commentable.try(:project)&.organization
    return unless org

    org.users.where("name ILIKE ANY (ARRAY[?])", mentioned_names.map { |n| n }).each do |mentioned_user|
      next if mentioned_user == user

      Notification.create!(
        user: mentioned_user,
        actor: user,
        action: "mentioned",
        notifiable: commentable
      )
    end
  end
end
