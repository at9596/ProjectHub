class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def show
    authorize @organization
    @members = @organization.users.order(:name, :email)
    @invitations_pending = User.where(organization: @organization).where.not(invitation_token: nil)
  end

  def update
    authorize @organization
    if @organization.update(organization_params)
      redirect_to organization_path, notice: "Workspace settings saved."
    else
      @members = @organization.users.order(:name, :email)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = current_user.organization
  end

  def organization_params
    params.require(:organization).permit(:name)
  end
end
