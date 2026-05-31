class ProjectPolicy < ApplicationPolicy
 def index?
    true
  end

  def show?
    true
  end

  def create?
    user.owner? || user.admin?
  end

  def update?
    user.owner? || user.admin?
  end

  def destroy?
    user.owner?
  end

  class Scope < Scope
    def resolve
      scope.where(
        organization_id: user.organization_id
      )
    end
  end
end
