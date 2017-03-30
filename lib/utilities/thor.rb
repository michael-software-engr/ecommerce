# ... edited by app gen (utilities)

require 'thor'

class ThorUtil
  class << self
    include Thor::Shell

    def info(msg, status: :info)
      say_status status, msg
    end

    def done(msg, status: :done)
      say_status status, msg, :cyan
    end

    def task(title = nil)
      if !title
        caller_info ||= caller.first
        title = File.basename(caller_info.split(':').first, '.rake')
      end
      say_status :TASK, title, :magenta
    end

    def no_status(msg = '')
      say_status nil, msg
    end

    def puts(msg = '')
      $stdout.puts msg
    end

    def ok
      say_status :ok, nil
    end

    def warning(msg = '...', status: :warn)
      say_status status, msg, :yellow
    end

    def failure(msg = '...', status: :error, do_raise: true)
      say_status status, msg, :red
      raise '...' if do_raise
    end
  end
end
