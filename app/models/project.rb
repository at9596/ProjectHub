class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :owner, class_name: "User"

  has_many :tasks, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user
  has_many :activities, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  enum :status, {
    active: 0,
    completed: 1,
    archived: 2
  }

  validates :name, presence: true

  # Log an activity on this project
  def log_activity(action:, user:, subject: nil, metadata: {})
    activities.create!(
      action: action,
      user: user,
      subject: subject,
      metadata: metadata
    )
  end
end
