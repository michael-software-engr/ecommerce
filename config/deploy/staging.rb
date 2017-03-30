# ... edited by app gen (Capistrano)

server(
  ENV.fetch('_staging_server_'),
  roles: %w[app web db],
  port: ENV.fetch('_sshport_'),
  primary: true
)

set :deploy_to, File.join(
  ENV.fetch('_remote_app_base_dir_'), fetch(:application)
) + '_staging'
