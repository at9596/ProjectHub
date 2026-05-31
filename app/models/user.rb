class User < ApplicationRecord
  rolify
  belongs_to :organization, optional: true
  enum :role, {
    owner: 0,
    admin: 1,
    member: 2,
    viewer: 3
  }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :invitable

  has_many :owned_projects,
           class_name: "Project",
           foreign_key: :owner_id,
           dependent: :nullify

  has_many :assigned_tasks,
           class_name: "Task",
           foreign_key: :assignee_id,
           dependent: :nullify

  has_many :project_memberships, dependent: :destroy
  has_many :member_projects, through: :project_memberships, source: :project

  has_many :comments, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :name, presence: true, on: :create
end
