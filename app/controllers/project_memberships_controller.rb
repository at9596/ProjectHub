class ProjectMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def create
    authorize @project, :update?

    user = @project.organization.users.find_by(email: params[:email])
    unless user
      redirect_to project_settings_path(@project), alert: "No user found with that email in your workspace."
      return
    end

    membership = @project.project_memberships.build(user: user, role: params[:role].presence || :contributor)
    if membership.save
      @project.log_activity(
        action: "added_member",
        user: current_user,
        subject: @project,
        metadata: { member_email: user.email }
      )
      redirect_to project_settings_path(@project), notice: "#{user.email} added to project."
    else
      redirect_to project_settings_path(@project), alert: membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @project, :update?
    membership = @project.project_memberships.find(params[:id])
    member_email = membership.user.email
    membership.destroy!
    @project.log_activity(
      action: "removed_member",
      user: current_user,
      subject: @project,
      metadata: { member_email: member_email }
    )
    redirect_to project_settings_path(@project), notice: "#{member_email} removed from project."
  end

  private

  def set_project
    @project = policy_scope(Project).find(params[:project_id])
  end
end
