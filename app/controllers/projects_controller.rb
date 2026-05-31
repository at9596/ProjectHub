class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: %i[show edit update destroy archive]

  def index
    @pagy, @projects = pagy(:keyset, policy_scope(Project).order(created_at: :desc), items: 10)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    authorize @project
    @activities = @project.activities.recent.includes(:user, :subject).limit(20)
    @members    = @project.members.includes(:project_memberships)
    @tasks_by_status = @project.tasks.group_by(&:status)
  end

  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    @project.owner       = current_user
    @project.organization = current_user.organization
    authorize @project

    if @project.save
      @project.log_activity(action: "created_project", user: current_user, subject: @project)
      redirect_to @project, notice: "Project created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project
    if @project.update(project_params)
      @project.log_activity(action: "updated_project", user: current_user, subject: @project)
      redirect_to @project, notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    authorize @project, :update?
    @project.update!(status: :archived)
    @project.log_activity(action: "archived_project", user: current_user, subject: @project)
    redirect_to projects_path, notice: "\"#{@project.name}\" has been archived."
  end

  def destroy
    authorize @project
    name = @project.name
    @project.destroy!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to projects_path, notice: "\"#{name}\" was deleted." }
    end
  end

  private

  def set_project
    @project = policy_scope(Project).find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :status, :due_date)
  end
end
