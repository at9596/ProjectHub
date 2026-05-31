class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assignee,
             class_name: "User",
             optional: true

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
end
