module AppGroupsHelper
  def max_tps(infrastructure)
    TPS_CONFIG[infrastructure.capacity]['max_tps']
  end

  def set_role_buttons(app_group_user, roles = {})
    current_role = app_group_user.role
    content_tag(:div, class: 'btn-group', role: 'group') do
      if roles[:member] != current_role
        concat link_to 'Set as Member', set_role_app_group_user_path(user_id: app_group_user.user_id, role_id: roles[:member]), class: 'btn btn-default', method: :patch
      end

      if roles[:admin] != current_role
        concat link_to 'Set as Admin', set_role_app_group_user_path(user_id: app_group_user.user_id, role_id: roles[:admin]), class: 'btn btn-default', method: :patch 
      end

      if roles[:owner] != current_role
        concat link_to 'Set as Owner', set_role_app_group_user_path(user_id: app_group_user.user_id, role_id: roles[:owner]), class: 'btn btn-default', method: :patch 
      end
    end
  end
end
