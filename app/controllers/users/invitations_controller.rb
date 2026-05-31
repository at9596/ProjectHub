# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  before_action :authenticate_user!, only: %i[new create]

  def create
    email = params.dig(:user, :email)
    role  = params.dig(:user, :role).presence || "member"

    # Check user doesn't already exist in this org
    if current_user.organization.users.exists?(email: email)
      redirect_to organization_path, alert: "#{email} is already a member of your workspace."
      return
    end

    @user = User.invite!(
      { email: email, name: email.split("@").first, role: role,
        organization: current_user.organization },
      current_user
    )

    if @user.errors.empty?
      redirect_to organization_path, notice: "Invitation sent to #{email}."
    else
      redirect_to organization_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  def update
    super do |user|
      if user.errors.empty?
        # Ensure org + role are set from invitation
        user.organization ||= current_inviter&.organization
        user.role ||= :member
        user.save(validate: false)
      end
    end
  end
end
