ActiveAdmin.register FacebookAccount do
  permit_params :active, :name, :api_identificator, :api_token, :facebook_group_account_id

  filter :name
  filter :active
  filter :facebook_group_account

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
      f.actions
    end
  end


  index do
    id_column
    column :active
    column :name
    column 'Account_id', :api_identificator
    column :api_token do |obj|
      truncate(obj.api_token)
    end
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
