set :log_level, :info
set :user, 'deploy'
set :application, 'screenshare-proto'
set :repo_url, 'https://github.com/nles/screenshare-proto.git'
ask :branch, 'master'
set :runner, 'deploy'
set :app_server, :puma
