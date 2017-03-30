# ... edited by app gen (utilities)

require_relative 'sys_exec'

def git_init
  if sys_exec!(
    'git status', verbose: false, error_display: :warning, raise_error: false
  )
    ThorUtil.done 'local git repo already initialized'
    return
  end

  ThorUtil.info 'initializing local git repo...'
  sys_exec!(
    'git init',
    'git add .',
    %w[git commit -m].push('Commit init'),
    verbose: false
  )
end

def git_remote_add(remote_name, repo)
  cmd_out = `git remote`

  if cmd_out =~ Regexp.new(Regexp.escape(remote_name))
    ssh_ip = ENV.fetch('_sship_').freeze
    ssh_port = ENV.fetch('_sshport_').freeze
    timeout = 10
    ssh_proto = 'SSH-protoversion-softwareversion SP comments CR LF'.freeze

    begin
      ThorUtil.info(
        "connecting to '#{ssh_ip}:#{ssh_port}' and sending '#{ssh_proto}'..."
      )
      Socket.tcp ssh_ip, ssh_port, nil, nil, connect_timeout: timeout do |sock|
        sock.print ssh_proto
        sock.close_write
        str = sock.read
        ThorUtil.done "OK: '#{str.chomp}'"
      end
    rescue Errno::ETIMEDOUT
      ThorUtil.failure "timed out in '#{timeout}'"
    end

    if sys_exec!(
      # Will connect with remote host, takes a few sec.
      # !! will take 2.8 min. if network connection fails.
      "git remote show #{remote_name}",
      verbose: false, error_display: :warning, raise_error: false
    )
      ThorUtil.done "git remote '#{remote_name}' already exists and is valid"
      return
    end
  end

  sys_exec! "git remote add #{remote_name} #{repo}"
end
