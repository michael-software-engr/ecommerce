# ... edited by app gen (layout)

module ApplicationHelper
  def alert_class_for(flash_type)
    case flash_type
    when 'success', 'successful_purchase'
      'alert-success'
    when 'error'
      'alert-danger'
    when 'alert'
      'alert-warning'
    when 'notice'
      'alert-info'
    else
      flash_type.to_s
    end
  end

  def path_or_id(path, id, append_id_to_path: true)
    full_id = "##{id}"
    return full_id if current_page?(path)
    return append_id_to_path ? "#{path}#{full_id}" : path
  end

  module App
    CAMEL = Rails.application.class.parent_name.freeze
    TITLE = CAMEL.titleize.freeze
    DASHERIZED = CAMEL.dasherize.freeze

    WORDS = TITLE.split(/\s+/).freeze
    FIRST_WORD = WORDS.first.freeze
    REST_OF_WORDS = WORDS[1..-1].join(' ').freeze

    TWITTER = 'https://twitter.com/'.freeze
    GITHUB = 'https://github.com/'.freeze
    GOOGLE_PLUS = 'https://plus.google.com/'.freeze

    # TWITTER = "https://twitter.com/#{CAMEL}".freeze
    # GITHUB = "https://github.com/#{DASHERIZED}/#{DASHERIZED}".freeze
    # GOOGLE_PLUS = "https://plus.google.com/+#{CAMEL}/posts".freeze

    private_constant :WORDS
  end
end
