class User < ApplicationRecord
  rolify
  belongs_to :organization
  enum :role, {
    owner: 0,
    admin: 1,
    member: 2,
    viewer: 3
  }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_many :owned_projects,
           class_name: "Project",
           foreign_key: :owner_id,
           dependent: :nullify

  has_many :assigned_tasks,
           class_name: "Task",
           foreign_key: :assignee_id,
           dependent: :nullify
end
