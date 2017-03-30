# ... edited by app gen (Puma)

class PumaPath
  class << self
    def validate_app_name_with(expected_app_name, using_abs_path:)
      anchor_string = 'releases'
      absolute_path = using_abs_path
      path_components = absolute_path.split(File::SEPARATOR)

      app_name = (
        if absolute_path =~ %r{/#{anchor_string}/}
          anchor_index = path_components.index(anchor_string)
          path_components[anchor_index - 1]
        else
          search_path_component = 'current'
          current_index = path_components.index(search_path_component)

          if !current_index
            raise(
              "'#{search_path_component}' path component not found" \
              ' ' \
              "in '#{path_components}'"
            )
          end

          path_components[current_index - 1]
        end
      )

      if app_name != expected_app_name
        raise(
          "app name from '#{absolute_path}' != expected '#{expected_app_name}'"
        )
      end

      return app_name
    end

    def app_dir_from(remote_app_base_dir, and_app_name:)
      File.join remote_app_base_dir, and_app_name, 'current'
    end

    def puma_dir_from(app_dir)
      File.join app_dir, %w[tmp puma]
    end

    def pid_dir_from(puma_dir)
      File.join puma_dir, 'pids'
    end

    def sockets_dir_from(puma_dir)
      File.join puma_dir, 'sockets'
    end

    def log_dir_from(puma_dir)
      File.join puma_dir, 'log'
    end

    def puma_sock_bname
      'puma.sock'
    end
  end
end
