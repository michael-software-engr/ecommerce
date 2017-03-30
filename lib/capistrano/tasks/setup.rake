# ... edited by app gen (Capistrano)

namespace :setup do
  desc 'Upload database.yml file.'
  task :upload_yml do
    on roles(:app) do
      dest_config_dir = "#{shared_path}/config"
      execute "mkdir -p #{dest_config_dir}"
      upload!(
        StringIO.new(File.read('config/database.yml')),
        "#{dest_config_dir}/database.yml"
      )

      figaro = 'config/application.yml'

      raise("\nFigaro file '#{figaro}' does not exist") if !File.exist?(figaro)
      upload!(
        StringIO.new(File.read(figaro)), "#{dest_config_dir}/application.yml"
      )

      upload!(
        StringIO.new(File.read('config/secrets.yml')),
        "#{dest_config_dir}/secrets.yml"
      )
    end
  end

  desc 'Create the database.'
  task :create_db do
    on roles(:app) do
      within current_path do
        with rails_env: :production do
          execute :rake, 'db:create'
        end
      end
    end
  end

  # Prob. a good idea to disable this.
  #   See related task in main virtual server rake file.
  # desc 'Drop the database.'
  # task :drop_db do
  #   on roles(:app) do
  #     within current_path do
  #       with rails_env: :production do
  #         execute :rake, 'db:drop'
  #       end
  #     end
  #   end
  # end

  desc 'Seed the database.'
  task :seed_db do
    on roles(:app) do
      within current_path do
        with rails_env: :production do
          execute :rake, 'db:seed'
        end
      end
    end
  end

  desc 'Symlinks config files for Nginx and Puma.'
  task :symlink_config do
    on roles(:app) do
      app_name = fetch :application

      # From template...
      puma_name = 'puma_your_website'.freeze
      puma_nginx_conf = 'config/puma_nginx.conf'.freeze
      puma_init_sh = 'config/puma_init.sh'.freeze

      puma_init = '/etc/init.d/' << puma_name
      execute 'sudo /bin/rm -f /etc/nginx/sites-enabled/default'
      execute "sudo /bin/ln -nfs #{current_path}/#{puma_nginx_conf}" \
              ' ' \
              "/etc/nginx/sites-enabled/#{app_name}"
      execute "sudo /bin/ln -nfs #{current_path}/#{puma_init_sh} #{puma_init}"
    end
  end
end
