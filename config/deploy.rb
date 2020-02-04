# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, 'facebook_ad_admin'
set :repo_url, 'git@github.com:w00lf/facebook_ad_admin.git'
set :deploy_to, '/home/advertisment/facebook_ad_admin_cap'
set :puma_init_active_record, true
set :rvm_ruby_version, '2.5.1'
set :sidekiq_processes, 2
set :sidekiq_options_per_process, ["--queue google_spreadsheet -c 1", "--queue default"]
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/config.json', 'config/secrets.yml', 'config/settings/production.yml', 'config/currency_iso.json')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')
set :keep_releases, 5