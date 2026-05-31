class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_task, only: %i[show edit update destroy]

  def index
    @tasks = policy_scope(Task).where(project: @project).includes(:assignee, :labels)
    @tasks_by_status = Task.statuses.keys.index_with do |status|
      @tasks.select { |t| t.status == status }
    end
  end

  def show
    authorize @task
    @comments = @task.comments.includes(:user).order(:created_at)
    @comment  = Comment.new
    @labels   = @project.organization.labels
  end

  def new
    @task = @project.tasks.build
    authorize @task
    @members = @project.organization.users
    @labels  = @project.organization.labels
  end

  def create
    @task = @project.tasks.build(task_params)
    authorize @task

    if @task.save
      @project.log_activity(action: "created_task", user: current_user, subject: @task)
      # Notify assignee
      if @task.assignee && @task.assignee != current_user
        Notification.create!(
          user: @task.assignee,
          actor: current_user,
          action: "assigned",
          notifiable: @task
        )
      end
      redirect_to project_task_path(@project, @task), notice: "Task created."
    else
      @members = @project.organization.users
      @labels  = @project.organization.labels
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @task
    @members = @project.organization.users
    @labels  = @project.organization.labels
  end

  def update
    authorize @task
    old_status = @task.status
    if @task.update(task_params)
      action = @task.status == "completed" && old_status != "completed" ? "completed_task" : "updated_task"
      @project.log_activity(action: action, user: current_user, subject: @task)
      redirect_to project_task_path(@project, @task), notice: "Task updated."
    else
      @members = @project.organization.users
      @labels  = @project.organization.labels
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task
    title = @task.title
    @task.destroy!
    @project.log_activity(action: "deleted_task", user: current_user, metadata: { title: title })
    redirect_to project_tasks_path(@project), notice: "\"#{title}\" deleted."
  end

  private

  def set_project
    @project = policy_scope(Project).find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :title, :description, :status, :priority,
      :due_date, :assignee_id, label_ids: []
    )
  end
end
