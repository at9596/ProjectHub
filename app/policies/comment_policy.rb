class CommentPolicy < ApplicationPolicy
  def create?
    !user.viewer?
  end

  def destroy?
    record.user == user || user.owner? || user.admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
