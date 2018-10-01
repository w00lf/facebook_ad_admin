ActiveAdmin.register ParseResult do
  # TODO: delete
  permit_params :error_text, :error_type, :status, :facebook_account_id

  index do
    column(:status) do |object|
      status_tag object.status, class: object.status, label: object.status
    end
    column(:error_type)
    column(:error_text)
    column(:facebook_account)
    column(:created_at)
  end
end
