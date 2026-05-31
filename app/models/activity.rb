class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true
  belongs_to :subject, polymorphic: true, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_project, ->(project) { where(project: project) }

  # Human-readable description of the activity
  def description
    subject_name = subject.try(:name) || subject.try(:title) || "##{subject_id}"
    case action
    when "created_project"  then "created project #{subject_name}"
    when "updated_project"  then "updated project #{subject_name}"
    when "archived_project" then "archived project #{subject_name}"
    when "created_task"     then "created task \"#{subject_name}\""
    when "updated_task"     then "updated task \"#{subject_name}\""
    when "completed_task"   then "completed task \"#{subject_name}\""
    when "deleted_task"     then "deleted task \"#{metadata['title']}\""
    when "added_member"     then "added #{metadata['member_email']} to the project"
    when "removed_member"   then "removed #{metadata['member_email']} from the project"
    when "commented"        then "left a comment"
    else action.humanize
    end
  end
end
