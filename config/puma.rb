# ... edited by app gen (Puma)

# ... this mess is needed because when deployed...
# /var/www/rails/#{app_name}/releases/20160924042002/{config,lib,...}

# ... from template '../lib/%{puma_path_util_require_path}'
require_relative '../lib/utilities/puma_path'

# ... if Capistrano, __FILE__ should have ...current/config... in its path.
if __FILE__ =~ Regexp.new('current/config')
  if !defined?(Rails) or !Rails.env.development?
    app_name = PumaPath.validate_app_name_with(
      # ... from template '%{expected_app_name}', using_abs_path...
      'your_website', using_abs_path: File.absolute_path(__FILE__)
    )

    # ****
    # Change to match your CPU core count
    workers 1

    # Min and Max threads per worker
    threads 1, 16

    # ... from template ... app_dir_from '%{remote_app_base_dir}'
    app_dir = PumaPath.app_dir_from '/var/www/rails',
                                    and_app_name: app_name

    # ...
    puma_dir = PumaPath.puma_dir_from app_dir
    pid_dir = PumaPath.pid_dir_from puma_dir
    sockets_dir = PumaPath.sockets_dir_from puma_dir
    log_dir = PumaPath.log_dir_from puma_dir

    FileUtils.mkdir_p [pid_dir, sockets_dir, log_dir]

    # Default to production
    rails_env = ENV['RAILS_ENV'] || 'production'
    environment rails_env

    bind "unix://#{sockets_dir}/#{PumaPath.puma_sock_bname}"

    # Logging
    stdout_redirect "#{log_dir}/puma.stdout.log",
                    "#{log_dir}/puma.stderr.log", true

    # Set master PID and state locations
    pidfile File.join(pid_dir, 'puma.pid')
    state_path File.join(pid_dir, 'puma.state')

    activate_control_app

    on_worker_boot do
      require 'active_record'
      begin
        ActiveRecord::Base.connection.disconnect!
      rescue ActiveRecord::ConnectionNotEstablished
        $stderr.puts(
          'ERROR ... rescued ActiveRecord::ConnectionNotEstablished ' \
          "'#{__FILE__}'"
        )
      end
      ActiveRecord::Base.establish_connection(
        YAML.load_file("#{app_dir}/config/database.yml")[rails_env]
      )
    end
  end
else
  # Default Puma config, mainly for Heroku.
  threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }.to_i
  threads threads_count, threads_count
  port        ENV.fetch('PORT') { 3000 }
  environment ENV.fetch('RAILS_ENV') { 'development' }
  plugin :tmp_restart
end
