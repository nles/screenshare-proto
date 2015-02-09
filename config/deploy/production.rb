set :stage, :production

# Server
# ======================
set :rvm_type, :system
set :host, "rtc.ymme.info"

# App
#========================
set :application, 'screenshare-proto'
set :scm, :git
set :branch, "master"
set :deploy_to, "/var/www/rails/#{fetch(:application)}"

# Roles
#========================
role :app, fetch(:host)
role :web, fetch(:host)
#role :db, fetch(:host), :primary => true

# serve
server fetch(:host), roles: [:web], user: 'deploy'
