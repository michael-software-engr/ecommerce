# ... edited by app gen (deployment to virtual server)

require 'utilities/thor'

def create_remote_git_repo(ssh, deploy_user, repo_url)
  ThorUtil.info "creating remote dir repo '#{repo_url}'..."

  branches_dir = File.join repo_url, 'branches'

  if ssh.dir_exist? branches_dir
    ThorUtil.done "'#{branches_dir}' exists, prob. already initialized"
  else
    git_cmd = 'git init --bare'
    ThorUtil.info "#{git_cmd} ..."
    ssh.exec! "sudo -u #{deploy_user} #{git_cmd} '#{repo_url}'"
  end
end
