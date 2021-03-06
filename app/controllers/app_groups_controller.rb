class AppGroupsController < ApplicationController
  include Wisper::Publisher
  before_action :set_app_group, only: [:show, :update, :manage_access]
  before_action only: [:show, :update, :manage_access] do
    authorize @app_group
  end

  def index
    @app_groups = policy_scope(AppGroup).order(:created_at)
    @allow_create_app_group = policy(Group).index?
    @allow_set_status = policy(Infrastructure).toggle_status?
  end

  def search
    @app_groups = policy_scope(AppGroup).where("name ILIKE :q", { q: "%#{params[:q]}%" })
    render json: @app_groups
  end

  def show
    @apps = @app_group.barito_apps
    @app = BaritoApp.new(app_group_id: @app_group.id)
    @barito_router_url = "#{Figaro.env.router_protocol}://#{Figaro.env.router_domain}/produce"
    @open_kibana_url = "#{Figaro.env.viewer_protocol}://#{Figaro.env.viewer_domain}/#{@app_group.infrastructure.cluster_name}"

    @allow_set_status = policy(@app).toggle_status?
    @allow_manage_access = policy(@app_group).manage_access?
    @allow_see_infrastructure = policy(Infrastructure).show?
    @allow_see_apps = policy(@app_group).allow_see_apps?
    @allow_delete_barito_app = policy(@app).delete?
    @allow_add_barito_app = policy(@app).create?
    @allow_edit_metadata = policy(@app_group).update?
    @allow_delete_infrastructure = policy(@app_group.infrastructure).delete?
  end

  def new
    authorize AppGroup
    @app_group = AppGroup.new
    @capacity_options = TPS_CONFIG.keys
  end

  def create
    authorize AppGroup
    @app_group, @infrastructure = AppGroup.setup(Rails.env, app_group_params)
    if @app_group.valid? && @infrastructure.valid?
      broadcast(:team_count_changed)
      return redirect_to root_path
    else
      flash[:messages] = @app_group.errors.full_messages
      flash[:messages] << @infrastructure.errors.full_messages
      return redirect_to new_app_group_path
    end
  end

  def update
    @app_group.update_attributes(app_group_params)
    redirect_to app_group_path(@app_group)
  end

  def manage_access
    @app_group_user = AppGroupUser.new(app_group: @app_group)
    @app_group_users = AppGroupUser.includes(:user, :role).where(app_group_id: @app_group.id).order(:created_at)

    @roles = {
      member: AppGroupRole.find_by_name('member'),
      admin: AppGroupRole.find_by_name('admin'),
      owner: AppGroupRole.find_by_name('owner')
    }
  end

  private

  def app_group_params
    params.require(:app_group).permit(
      :name,
      :capacity
    )
  end

  def set_app_group
    @app_group = AppGroup.find(params[:id])
  end
end
