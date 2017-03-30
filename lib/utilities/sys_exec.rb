# ... edited by app gen (utilities)

require 'utilities/thor'

# cmd_string_list = ['cmd1', 'cmd2 and args'] => ...
#   system cmd1... system 'cmd2', 'and', 'args'
# error_display: ... the methods above, failure, warning or nil
#   if you don't want to display anything.
def sys_exec!(
  *cmd_list,
  verbose: true, error_display: :failure, raise_error: true
)
  SysExec.new(cmd_list, verbose, error_display, raise_error).run
end

class SysExec
  include Thor::Shell

  def initialize(cmd_list, verbose, error_display, raise_error)
    @cmd_list = cmd_list
    @verbose = verbose
    @error_display = error_display
    @raise_error = raise_error
  end

  def run
    cmd_list.each do |cmd|
      cmd_components = components_of cmd

      ThorUtil.info cmd_components, status: :run

      options = {}
      options = options.merge(out: File::NULL, err: File::NULL) if !verbose

      failed = false
      system(*cmd_components, options) || failed = true

      next if !failed

      ThorUtil.public_send error_display, '^^^ failed' if error_display
      raise if raise_error
      break
    end
  end

  private

  attr_reader :cmd_list, :verbose, :error_display, :raise_error

  def components_of(cmd)
    case cmd
    when String then cmd.split(/\s+/)
    when Array then cmd
    else raise "Unsupported cmd format '#{cmd}'"
    end
  end
end
