ActiveAdmin.register BinomServer do
  permit_params :url,
                :api_key

  actions :index, :new, :create, :edit, :update

  filter :url_cont
end
