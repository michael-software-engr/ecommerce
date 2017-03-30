# ... edited by app gen (Capistrano)

require_relative '../../utilities/thor'

namespace :deploy do
  before :restart, 'setup:symlink_config'

  desc 'Makes sure local git is in sync with remote.'
  task :check_revision do
    # From template %{git_remote_name}/master
    unless `git rev-parse HEAD` == `git rev-parse virtual_server/master`
      ThorUtil.failure(
        'HEAD is not the same as virtual_server/master...', do_raise: false
      )
      ThorUtil.no_status 'run `git push` to sync changes.'
      exit 1
    end

    git_status = `git status`
    [
      'untracked \s+ files',
      'changes \s+ to \s+ be \s+ committed',
      'changes \s+ not \s+ staged \s+ for \s+ commit'
    ].each do |error_status|
      err_status_re = Regexp.new(
        error_status, Regexp::EXTENDED | Regexp::MULTILINE | Regexp::IGNORECASE
      )
      next if git_status !~ err_status_re

      border = ('# ' + '-' * 100 + ' #').freeze
      ThorUtil.warning "error status '#{error_status}' found..."
      ThorUtil.no_status
      ThorUtil.puts border
      ThorUtil.puts git_status
      ThorUtil.puts border
      ThorUtil.no_status
      ThorUtil.info([
        'git add .', 'git commit -am "..."',
        # From template ... -u %{git_remote_name} master
        'git push -u virtual_server master'
      ].join(' && '), status: :fix)

      exit 1
    end
  end

  operations = %w[start stop restart status].freeze # %
  operations.each do |command|
    desc "#{command} Puma server."
    task command do
      on roles(:app) do
        # execute "sudo /usr/sbin/service puma_#{fetch :application} #{command}"
        execute "/etc/init.d/puma_#{fetch :application} #{command}"
        execute 'sudo systemctl restart nginx'
      end
    end
  end

  desc 'Undo deploy.'
  task :undo do
    on roles(:app) do
      app_name = fetch :application

      # From template
      puma_name = 'puma_your_website'.freeze
      remote_app_base_dir = '/var/www/rails'.freeze
      remote_git_base_base_dir = '/var/git'.freeze

      cmd = [
        "/etc/init.d/#{puma_name} stop",
        "sudo /bin/rm -f '/etc/nginx/sites-enabled/#{app_name}'",
        "sudo /bin/rm -f '/etc/init.d/#{puma_name}'",
        "sudo /bin/rm -rf '#{remote_app_base_dir}/#{app_name}'",
        'sudo /bin/rm -rf' \
          ' ' \
          "'#{remote_git_base_base_dir}/#{fetch :deploy_user}/#{app_name}.git'"
      ].join(';')

      execute cmd
    end
  end

  before :deploy, 'deploy:check_revision'
  after :deploy, 'deploy:restart'
  after :rollback, 'deploy:restart'
end
