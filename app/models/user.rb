class User < ApplicationRecord
  # Enums
  enum :role, {
    owner: 0,
    admin: 1,
    member: 2,
    viewer: 3
  }

  # Validations
  validates :name, presence: true, on: :create

  # Associations

  with_options dependent: :destroy do |assoc|
    assoc.has_many :notifications
    assoc.has_many :activities
    assoc.has_many :comments
    assoc.has_many :project_memberships
  end

  belongs_to :organization, optional: true

  has_many :owned_projects,
           class_name: "Project",
           foreign_key: :owner_id,
           dependent: :nullify

  has_many :assigned_tasks,
           class_name: "Task",
           foreign_key: :assignee_id,
           dependent: :nullify

  has_many :member_projects, through: :project_memberships, source: :project

  # Devise modules
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :invitable
end
