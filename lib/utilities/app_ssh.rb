# ... edited by app gen (utilities)

require 'net/ssh'
require 'utilities/thor'

class AppSSH
  def initialize(**kw_args)
    validate_args kw_args, required: %i[
      remote_user
      ip
      port
      host
    ], optional: {
      assert_ok_to_sudo: false
    }
  end

  def start
    Net::SSH.start(ip, remote_user, port: port) { |ssh| yield ssh }
  end

  def dir_exist?(dir)
    (exec! "test -d '#{dir}'", raise_exception_on_error: false).success?
  end

  def exist?(file)
    (exec! "test -e '#{file}'", raise_exception_on_error: false).success?
  end

  def create_dirs(*dirs, sudo: false, owner: 'root', verbose: true)
    dirs.each do |dir|
      ThorUtil.info "creating remote dir '#{dir}'..." if verbose
      if dir_exist?(dir)
        ThorUtil.done '... already exists' if verbose
        next
      end

      cmd = "mkdir -p '#{dir}'"
      cmd = "sudo #{cmd}" if sudo
      exec! cmd

      exec! "sudo chown #{owner}:#{owner} '#{dir}'"

      ThorUtil.ok if verbose
    end
  end

  def exec!(command, sudo: false, raise_exception_on_error: true)
    command = "sudo #{command}" if sudo
    stdout_data = ''
    stderr_data = ''

    exit_code = nil
    exit_signal = nil

    start do |ssh|
      ssh.open_channel do |channel|
        channel.exec(command) do |_, success|
          raise "Command \"#{command}\" was unable to execute" unless success

          channel.on_data { |_, data| stdout_data += data }
          channel.on_extended_data { |_, _, data| stderr_data += data }

          channel.on_request('exit-status') do |_, data|
            exit_code = data.read_long
          end

          channel.on_request('exit-signal') do |_, data|
            exit_signal = data.read_long
          end
        end
      end
      ssh.loop

      assert_no_error!(
        exit_code, raise_exception_on_error, command, stderr_data, stdout_data
      )

      return Struct.new(
        :stdout, :stderr,
        :exit_code, :exit_signal, :success?
      ).new(
        stdout_data, stderr_data,
        exit_code, exit_signal, (exit_code.zero? ? true : false)
      )
    end
  end

  def assert_ok_to_sudo!
    exec! 'sudo -n /usr/bin/uptime'
  end

  private

  def validate_args(kw_args, required:, optional: nil)
    diff = required - kw_args.keys
    raise "Required arg missing, #{diff}" if !diff.empty?

    required.each do |var_sym|
      instance_variable_set "@#{var_sym}", kw_args[var_sym]
      self.class.class_eval { attr_reader var_sym }
    end

    return if !optional
    optional.each do |var_sym, default_value|
      instance_variable_set("@#{var_sym}", kw_args[var_sym] || default_value)
      self.class.class_eval { attr_reader var_sym }
    end
  end

  def assert_no_error!(
    exit_code, raise_exception_on_error, command, stderr_data, stdout_data
  )
    return if exit_code.zero?
    return if !raise_exception_on_error
    $stderr.puts
    raise(
      "...\n" \
      "Command \"#{command}\" returned exit code #{exit_code}\n" \
      "Std err: '#{stderr_data.chomp}'\n" \
      "Std out: '#{stdout_data.chomp}'"
    )
  end
end
