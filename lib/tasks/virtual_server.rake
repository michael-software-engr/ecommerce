# ... edited by app gen (deployment to virtual server)

require 'utilities/main'
require 'utilities/thor'
require 'utilities/sys_exec'

require_relative relative_dir 'vserver_task', ext: '.rake'

# WTF? This is needed to fill task.comment
# desc 'Some desc'
# task some_task: :environment do |current_task|
#   p current_task.comment
# ...
# If the code below is not included,
#   current_task.comment will be nil
Rake::TaskManager.record_task_metadata = true

namespace :VSERVER do |this_ns|
  vserver_task = VServerTask.new(this_ns).freeze

  # ... from template: remote_name = '%{git_remote_name}'.freeze
  remote_name = 'virtual_server'.freeze

  desc 'Deploy'
  task deploy: :environment do
    task_list = %w[setup git:usual].freeze # %
    task_list
      .map { |task_name| "#{vserver_task.namespace}:#{task_name}" }
      .each do |task_name|
      subtask = Rake.application[task_name]
      ThorUtil.task task_title subtask
      subtask.invoke
      ThorUtil.say_status nil, ''
    end

    forced_env = 'production'.freeze

    ThorUtil.info 'execute manually for better output formatting...'
    ThorUtil.no_status [
      "cap #{forced_env} setup:upload_yml", "cap #{forced_env} deploy"
    ].join(' && ')

    # ThorUtil.warning "forced env '#{forced_env}'"
    # sys_exec! "cap #{forced_env} setup:upload_yml", "cap #{forced_env} deploy"

    # ... Other...
    ThorUtil.info 'other cmds, execute manually...'
    ThorUtil.no_status(
      [
        "cap #{forced_env} invoke task=db:seed",
        "cap #{forced_env} invoke task=IMAGES:get"
      ].join(' && ')
    )
  end

  desc 'Main task runner, virtual server setup'
  task setup: :environment do |current_task|
    ThorUtil.task task_title current_task

    task_list = %w[files git:setup db:create].freeze # %
    task_list
      .map { |task_name| "#{vserver_task.namespace}:#{task_name}" }
      .each do |task_name|
      subtask = Rake.application[task_name]
      ThorUtil.task task_title subtask
      subtask.invoke
      ThorUtil.say_status nil, ''
    end
  end

  desc 'Create files on remote server'
  task files: :environment do
    vserver_task.ssh.assert_ok_to_sudo!

    require_relative relative_dir 'dirs', ext: '.rake'
    create_remote_dirs vserver_task.ssh, vserver_task.deploy_user
  end

  namespace :git do
    desc 'Local and remote git setup'
    task setup: :environment do
      require_relative relative_dir 'remote_git_repo', ext: '.rake'
      create_remote_git_repo(
        vserver_task.ssh, vserver_task.deploy_user, ENV.fetch('_repo_url_')
      )

      require_relative relative_dir 'local_git_repo', ext: '.rake'

      setup_local_git_repo(
        vserver_task.deploy_user, vserver_task.ssh_param, remote_name
      )
    end

    desc 'Usual git status => add => commit => push cycle'
    task usual: :environment do |task_name|
      commit_msg_env_var = 'msg'.freeze
      commit_msg = (
        ENV[commit_msg_env_var] || "Commit push to '#{remote_name}'"
      ).freeze

      git_status = 'git status'.freeze

      force_evar = 'force'.freeze
      push_cmd = "git push -u #{remote_name} master"
      push_cmd += ' --force' if ENV[force_evar]

      git_cmds = [
        { cmd: git_status },
        { cmd: 'git add .' },
        { cmd: ['git', 'commit', '-m', commit_msg], raise_error: false },
        { cmd: push_cmd },
        { cmd: git_status }
      ].freeze

      ThorUtil.info      "task '#{task_name}', env vars..."
      ThorUtil.no_status "'#{force_evar}' - set git push --force"
      ThorUtil.no_status "'#{commit_msg_env_var}' - set commit msg"
      ThorUtil.no_status 'Will execute the following...'

      git_cmds.each do |cmd|
        ThorUtil.no_status "  #{cmd}"
      end

      git_cmds.each do |cmd:, raise_error: true|
        error_display = raise_error ? :failure : :warning
        sys_exec! cmd, raise_error: raise_error, error_display: error_display
      end
    end
  end

  # Don't know if necessary. cap tasks seems to work OK.
  # namespace :puma do
  #   appname = ENV.fetch('_application_').freeze
  #   operations = %w[start stop restart status].freeze # %
  #   operations.each do |command|
  #     desc "#{command} Puma server."
  #     task command => :environment do
  #       vserver_task.ssh.exec! "/etc/init.d/puma_#{appname} #{command}"
  #       vserver_task.ssh.exec! 'sudo systemctl restart nginx'
  #     end
  #   end
  # end

  namespace :db do
    # Not sure if good idea to make it dependent on env or
    #   just hard-code "production", 3 options:
    # 1. ...fetch(Rails.env)
    # 2. ...fetch(ENV['RAILS_ENV'])
    #       RAILS_ENV not recognized by Zeus so you
    #       must run as `zeus rake namespace:this_task RAILS_ENV=desired_env
    # 3. ...fetch('production')
    db_name = Rails.configuration.database_configuration
                   .fetch('production')
                   .fetch('database').freeze

    def db_exists?(ssh, deploy_user, db_name)
      out = ssh.exec! "sudo -i -u #{deploy_user} /usr/bin/psql -lqt"
      result = false

      out.stdout.split(/\n+/).each do |line|
        current_db = line.split(/[|]/).first.strip
        next if current_db.strip.blank?

        if current_db == db_name
          result = true
          break
        end
      end

      return result
    end

    desc 'DB...'
    task create: :environment do
      ThorUtil.info "creating DB '#{db_name}'..."
      if db_exists? vserver_task.ssh, vserver_task.deploy_user, db_name
        ThorUtil.done 'already exists'
      else
        cmd = "sudo -i -u #{vserver_task.deploy_user}" \
          " createdb --echo #{db_name}".freeze

        ThorUtil.info "SSH `#{cmd}`"
        vserver_task.ssh.exec! cmd
        ThorUtil.ok
      end
    end

    desc 'DROP!!!'
    task drop: :environment do
      ThorUtil.warning 'drop manually...'
      ThorUtil.say_status nil, [
        'ssh', '-p', vserver_task.ssh_param.port,
        [vserver_task.deploy_user, vserver_task.ssh_param.ip].join('@'),
        'dropdb', '--echo', db_name
      ].join(' ')
    end
  end
end
