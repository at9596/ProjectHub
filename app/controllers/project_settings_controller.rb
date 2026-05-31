class ProjectSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def show
    authorize @project, :update?
    @memberships = @project.project_memberships.includes(:user).order("users.email")
    @org_members = @project.organization.users.where.not(id: @project.member_ids)
  end

  private

  def set_project
    @project = policy_scope(Project).find(params[:project_id])
  end
end
