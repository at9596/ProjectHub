class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :owner, class_name: "User"

  has_many :tasks, dependent: :destroy

  enum :status, {
    active: 0,
    completed: 1,
    archived: 2
  }

  validates :name, presence: true
end
