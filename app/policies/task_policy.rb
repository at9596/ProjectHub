class TaskPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    !user.viewer?
  end

  def update?
    user.owner? || user.admin? || record.assignee == user
  end

  def destroy?
    user.owner? || user.admin?
  end

  class Scope < Scope
    def resolve
      scope.joins(:project).where(projects: { organization_id: user.organization_id })
    end
  end
end
