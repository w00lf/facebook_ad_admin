ActiveAdmin.register FacebookAccount do
  permit_params :active, :name, :api_identificator, :api_token, :facebook_group_account_id
  batch_action :destroy, false
  batch_action :get_daily_limit do |ids|
    ids.each_slice(5) do |batch|
      FetchFacebookBmDailyLimitJob.perform_later(batch)
    end
    redirect_to request.referer, alert: "Queued daily limit fetch, refresh this page in a couple of seconds"
  end

  filter :name, as: :select, multiple: true, collection: FacebookAccount.active.pluck(:name)
  filter :active
  filter :facebook_group_account

  member_action :hide_comments do
    FacebookAccountHideCommentsJob.perform_later(resource.id)
    redirect_to resource_path, notice: 'Queued hide comments on this account'
  end

  action_item :hide_comments, only: :show do
    link_to 'Hide comments', hide_comments_admin_facebook_account_path(resource)
  end

  member_action :rescan do
    FacebookAccountStatsRetrieveJob.perform_later((1.days.ago).to_i, resource.id)
    redirect_to resource_path, notice: 'Queued rescan of the account'
  end

  action_item :rescan, only: :show do
    link_to 'Rescan for yesterday', rescan_admin_facebook_account_path(resource)
  end

  form do |f|
    f.inputs do
      f.semantic_errors(*f.object.errors.keys)
      f.input :facebook_group_account
      f.input :name
      f.input :api_identificator
      f.input :api_token
      f.input :active
      f.actions
    end
  end


  index do
    selectable_column
    id_column
    column :active
    column :name
    column 'Account_id', :api_identificator
    column :facebook_group_account
    column :parse_status do |obj|
      last_parse_result = obj.parse_results.last
      if last_parse_result
        status_tag last_parse_result.status, class: last_parse_result.status, label: last_parse_result.status
        link_to('more', admin_parse_result_path(last_parse_result)) if last_parse_result.status == 'error'
      end
    end
    column :daily_limit_updated_at
    column :daily_limit do |obj|
      if obj.daily_limit_updated_at
        obj.daily_limit
      end
    end
    actions
  end
end
