class RoomsUserPolicy < ApplicationPolicy
  def create?
    record.room.user_id == user.id
  end

  def destroy?
    create?
  end
end
