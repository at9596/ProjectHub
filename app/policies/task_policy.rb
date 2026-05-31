class TaskPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    !user.viewer?
  end

  def update?
    return true if user.owner?
    return true if user.admin?

    record.assignee == user
  end

  def destroy?
    user.owner? || user.admin?
  end
end
