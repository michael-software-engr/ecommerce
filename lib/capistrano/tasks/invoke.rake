# ... edited by app gen (Capistrano)

desc 'Invoke rake task on the server'
task :invoke do
  task_env_var = 'task'
  task_name = ENV[task_env_var]

  if !task_name
    raise(
      "No task provided, provide task using env var '#{task_env_var}=task:name'"
    )
  end

  on roles :app do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, task_name, *ARGV[2..-1]
      end
    end
  end
end
