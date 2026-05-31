class ProjectMembership < ApplicationRecord
  belongs_to :project
  belongs_to :user

  enum :role, {
    manager: 0,
    contributor: 1,
    viewer: 2
  }

  validates :user_id, uniqueness: { scope: :project_id, message: "is already a member of this project" }
end
