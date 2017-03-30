# ... edited by app gen (Capistrano)

require 'figaro'

Figaro.application = Figaro::Application.new(
  environment: ARGV[0].to_s,
  path: File.join(__dir__, 'application.yml')
)
Figaro.load

lock ENV.fetch '_capistrano_lock_'

set :application, ENV.fetch('_application_')
set :deploy_user, ENV.fetch('_deploy_user_')

# Example: set :repo_url, '/var/git/user/appname.git'
set :repo_url, ENV.fetch('_repo_url_')
set :rbenv_type, :user
set :rbenv_ruby, ENV.fetch('_ruby_version_')

# ... why one entry for deploy_user and ssh_options...user?
#     If we should have separate deploy and SSH users in the future.
set :ssh_options, user: ENV.fetch('_deploy_user_')
set :rbenv_custom_path, ENV.fetch('_rbenv_custom_path_')

set :rbenv_prefix, [
  "RBENV_ROOT=#{fetch(:rbenv_path)}",
  "RBENV_VERSION=#{fetch(:rbenv_ruby)}",
  'RBENV_GEMSETS=rails',
  [File.join(fetch(:rbenv_path), %w[bin rbenv]), 'exec'].join(' ')
].join(' ')

set :rbenv_map_bins, %w[rake gem bundle ruby rails]

# ... default value, not in source 1.
set :rbenv_roles, :all

# ... NEWEST debug
set :bundle_flags, '--system'
# ... the issue with bundler not installing in the "global (rbenv)" path.
#     bundle_path must be set to nil.
set :bundle_path, nil
# ... must anon-proc-ify if you want to set this, like this...
# set :bundle_path, -> { '/some/path' }

set(
  :default_env,

  path: "#{fetch(:rbenv_path)}/shims:#{fetch(:rbenv_path)}/bin:$PATH",

  # # ... example to set other env vars
  # '_other_env_var_' => ENV.fetch('_other_env_var_')
)

linked_file_list = %w[config/database.yml config/secrets.yml]
figaro_file = 'config/application.yml'
linked_file_list << figaro_file if File.exist? figaro_file

set :linked_files, linked_file_list
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system'
)

set :keep_releases, 3
