class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @pagy, @projects = pagy(:keyset, policy_scope(Project).order(created_at: :desc), items: 10)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    authorize @project
  end

  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    @project.owner = current_user
    @project.organization = current_user.organization
    authorize @project

    if @project.save
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
      redirect_to @project, notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    authorize @project
    @project.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to projects_path, notice: "Project deleted successfully." }
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
