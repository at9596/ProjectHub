class LabelPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    !user.viewer?
  end

  def update?
    !user.viewer?
  end

  def destroy?
    user.owner? || user.admin?
  end

  class Scope < Scope
    def resolve
      scope.where(organization: user.organization)
    end
  end
end
