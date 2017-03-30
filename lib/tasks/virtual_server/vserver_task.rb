# ... edited by app gen (deployment to virtual server)

require 'utilities/app_ssh'

class VServerTask
  attr_reader :namespace, :ssh_param, :deploy_user, :ssh

  def initialize(this_ns)
    @namespace = this_ns.scope.path.freeze
    @ssh_param = ssh_param_build
    @deploy_user = ENV.fetch('_deploy_user_').freeze

    @ssh = AppSSH.new @ssh_param.all
  end

  private

  def ssh_param_build
    remote_user = ENV.fetch('_remote_user_').freeze
    ip = ENV.fetch('_sship_').freeze
    port = ENV.fetch('_sshport_').freeze
    host = ENV.fetch('_sshhost_').freeze
    all = {
      remote_user: remote_user, ip: ip, port: port, host: host
    }.freeze

    return Struct.new(
      :remote_user, :ip, :port, :host, :all
    ).new(
      remote_user, ip, port, host, all
    ).freeze
  end
end
