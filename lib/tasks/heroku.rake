# ... edited by app gen (DB seeder, Rake tasks, etc...)

require 'utilities/main'
require 'utilities/thor'
require 'utilities/sys_exec'
require 'utilities/git'

# WTF? This is needed to fill task.comment
# desc 'Some desc'
# task some_task: :environment do |current_task|
#   p current_task.comment
# ...
# If the code below is not included,
#   current_task.comment will be nil
Rake::TaskManager.record_task_metadata = true

namespace :HEROKU do |this_ns|
  namespace = this_ns.scope.path.freeze

  heroku_task = Struct.new(
    :force_evar, :namespace, :list
  ).new(
    'force'.freeze, namespace, %w[
      git
      assets_rebuild
      git_push
    ].map { |task_name| "#{namespace}:#{task_name}" }.freeze
  )

  force_comment = "set env var '#{heroku_task.force_evar}' " \
    'to git push --force ....'.freeze

  desc 'Main task runner, deploy to Heroku'
  task deploy: :environment do |current_task|
    ThorUtil.task task_title current_task

    heroku_task.list.each do |task_name|
      subtask = Rake.application[task_name]
      ThorUtil.task task_title subtask
      subtask.invoke
      ThorUtil.say_status nil, ''
    end

    sys_exec! 'figaro heroku:set'
    sys_exec! 'heroku run rake db:migrate'
    sys_exec! 'heroku run rake db:seed'
    sys_exec! 'heroku run rake IMAGES:get'
  end

  desc 'Help'
  task help: :environment do |current_task|
    help(
      current_task,
      text_list: [force_comment],
      tasks_to_run: heroku_task.list
    )
  end

  desc 'git rm -rf public/assets'
  task git: :environment do
    git_init

    cmdout = `git remote -v`

    dasherized_appname = Rails.application.class.parent_name
                              .underscore.dasherize.freeze

    if cmdout !~ /heroku/
      raise(
        "Heroku remote not found...\n" +
        cmdout + " Do ...\n" \
        "  heroku apps:create #{dasherized_appname} # OR...\n" \
        '  git remote add heroku ' \
        "https://git.heroku.com/#{dasherized_appname}.git\n\n"
      )
    end

    ThorUtil.done 'Heroku remote OK...'
    ThorUtil.puts cmdout

    # ... I DON'T know WTF I was doing here.
    # git_remote_add 'heroku', ENV.fetch('HEROKU_REPO')

    sys_exec!(
      'git rm -rf public/assets',
      verbose: false, error_display: :warning, raise_error: false
    )
  end

  desc 'assets:clobber assets:precompile'
  task :assets_rebuild do
    %w[
      assets:clobber
      assets:precompile
    ].each do |task_name|
      system({ 'RAILS_ENV' => 'production' }, 'bin/rails', task_name)
      ThorUtil.say_status nil, ''
    end
  end

  desc "Push to Heroku, #{force_comment}"
  task git_push: :environment do
    push_cmd = 'git push -u heroku master'
    push_cmd += ' --force' if ENV[heroku_task.force_evar]

    sys_exec!(
      'git add .',
      ['git', 'commit', '-m', "Run task #{heroku_task.namespace}:*"],
      push_cmd
    )
  end

  desc '!!!'
  task PRODUCTION_DB_RESET: :environment do
    sys_exec!(
      'heroku pg:reset DATABASE',
      'heroku run rake db:migrate db:seed IMAGES:get'
    )
  end
end
