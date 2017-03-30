# ... edited by app gen (deployment to virtual server)

require 'utilities/thor'
require 'utilities/sys_exec'
require 'utilities/git'

def setup_local_git_repo(deploy_user, ssh_param, remote_name)
  git_init

  git_remote_add(
    remote_name,
    "ssh://#{deploy_user}@#{ssh_param.ip}:#{ssh_param.port}" +
    ENV.fetch('_repo_url_')
  )
end
