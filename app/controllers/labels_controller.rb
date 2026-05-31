class LabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_label, only: %i[edit update destroy]

  def index
    authorize Label
    @labels = current_user.organization.labels.order(:name)
  end

  def new
    @label = Label.new
    authorize @label
  end

  def create
    @label = current_user.organization.labels.build(label_params)
    authorize @label

    if @label.save
      redirect_to labels_path, notice: "Label \"#{@label.name}\" created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @label
  end

  def update
    authorize @label
    if @label.update(label_params)
      redirect_to labels_path, notice: "Label updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @label
    @label.destroy!
    redirect_to labels_path, notice: "Label deleted."
  end

  private

  def set_label
    @label = current_user.organization.labels.find(params[:id])
  end

  def label_params
    params.require(:label).permit(:name, :color)
  end
end
