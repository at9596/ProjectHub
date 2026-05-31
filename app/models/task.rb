class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assignee, class_name: "User", optional: true

  has_rich_text :description
  has_many_attached :attachments

  has_many :task_labels, dependent: :destroy
  has_many :labels, through: :task_labels
  has_many :comments, as: :commentable, dependent: :destroy

  enum :status, {
    todo: 0,
    in_progress: 1,
    review: 2,
    completed: 3
  }

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2,
    urgent: 3
  }

  validates :title, presence: true

  delegate :organization, to: :project
end
