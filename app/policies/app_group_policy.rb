class AppGroupPolicy < ApplicationPolicy
  def show?
    return true if get_user_groups

    app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
    app_group_ids.include?(record.id)
  end

  def new?
    return true if get_user_groups
    false
  end

  def create?
    new?
  end

  def update?
    return true if get_user_groups

    record.app_group_users.
      joins(:role).
      where(user: user, app_group_roles: { name: [:owner, :admin] }).count > 0
  end

  def manage_access?
    return true if get_user_groups

    record.app_group_users.
      joins(:role).
      where(user: user, app_group_roles: { name: [:owner] }).count > 0
  end

  def allow_see_apps?
    return true if get_user_groups

    user.app_groups.where(id: record.id).count > 0
  end

  class Scope < Scope
    def resolve
      if Figaro.env.enable_cas_integration == 'true'
        gate_groups = GateWrapper.new(user).check_user_groups.symbolize_keys[:groups] || []
        return scope.active if Group.where(name: gate_groups).count > 0
      else
        return scope.active if user.groups.count > 0
      end

      app_group_ids = AppGroupUser.where(user: user).pluck(:app_group_id)
      scope.active.where(id: app_group_ids)
    end
  end
end
