# ... edited by app gen (DB seeder, Rake tasks, etc...)

# ... HACK: https://github.com/guard/listen/wiki/Duplicate-directory-errors

if Rails.env.development?
  require 'listen/record/symlink_detector'
  module Listen
    class Record
      class SymlinkDetector
        def _fail(_, _)
          raise Error, "Don't watch locally-symlinked directory twice"
        end
      end
    end
  end
end
