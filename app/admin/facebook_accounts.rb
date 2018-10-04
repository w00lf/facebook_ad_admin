ActiveAdmin.register FacebookAccount do
  permit_params :active, :name, :api_identificator, :api_token, :api_secret, :facebook_group_account_id

  member_action :rescan do
    FacebookAccountStatsRetrieveJob.perform_async((1.days.ago).to_i, resource.id)
    redirect_to resource_path, notice: 'Queued rescan of the account'
  end

  action_item :rescan, only: :show do
    link_to 'Rescan for yesterday', rescan_admin_facebook_account_path(resource)
  end


  index do
    id_column
    column :active
    column :name
    column 'Account_id', :api_identificator
    column :api_token do |obj|
      truncate(obj.api_token)
    end
    column :api_secret
    column :facebook_group_account
    column :parse_status do |obj|
      last_parse_result = obj.parse_results.last
      if last_parse_result
        status_tag last_parse_result.status, class: last_parse_result.status, label: last_parse_result.status
        link_to('more', admin_parse_result_path(last_parse_result)) if last_parse_result.status == 'error'
      end
    end
    actions
  end
end
