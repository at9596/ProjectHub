class OrganizationPolicy < ApplicationPolicy
  def show?
    record == user.organization
  end

  def update?
    user.owner? && record == user.organization
  end

  class Scope < Scope
    def resolve
      scope.where(id: user.organization_id)
    end
  end
end
