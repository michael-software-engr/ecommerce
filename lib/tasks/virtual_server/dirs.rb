# ... edited by app gen (deployment to virtual server)

def create_remote_dirs(ssh, deploy_user)
  ssh.create_dirs(
    ENV.fetch('_remote_app_base_dir_'), ENV.fetch('_repo_url_'),
    sudo: true,
    owner: deploy_user
  )
end
