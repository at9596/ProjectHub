class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_task

  def create
    @comment = @task.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      @project.log_activity(action: "commented", user: current_user, subject: @task)
      redirect_to project_task_path(@project, @task), notice: "Comment added."
    else
      redirect_to project_task_path(@project, @task), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @comment = @task.comments.find(params[:id])
    authorize @comment
    @comment.destroy!
    redirect_to project_task_path(@project, @task), notice: "Comment deleted."
  end

  private

  def set_project
    @project = policy_scope(Project).find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
