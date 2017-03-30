# ... edited by app gen (other pages)

module OtherPagesHelper
  def contact
    return MoreInfoSection.new(title: 'Contact', links: [
      { text: 'Sales', message: 'Sales contact information' },
      { text: 'Email', path: email_form_path },
      { text: 'HQ Address/Map', path: map_path },
      { text: 'US: 1(888) 987-6543', path: 'tel:18889876543' },
      { text: 'UK: +44 (0)20 9876 5432', path: 'tel:4402098765432' }
    ]).freeze
  end

  def what_we_do
    return MoreInfoSection.new(title: 'What We Do', links: [
      { text: 'Background', message: 'Company background' },
      { text: 'Products', path: products_path },
      { text: 'Services', path: landing_page_index_path + '#services' }
    ]).freeze
  end

  def resources
    return MoreInfoSection.new(title: 'Resources', links: [
      { text: 'Support', message: 'Support page/forum' },
      { text: 'Documentation' },
      { text: 'Blog' }
    ]).freeze
  end

  def about_us
    return MoreInfoSection.new(title: 'About Us', links: [
      { text: 'Overview', message: 'Company overview' },
      { text: 'Our Team' },
      { text: 'Careers' },
      { text: 'Press' },
      { text: 'Privacy Policy' },
      { text: 'Terms of Service' }
    ]).freeze
  end

  class MoreInfoSection
    include Rails.application.routes.url_helpers

    ATTRS = %i[title links].freeze

    private_constant :ATTRS

    attr_reader(*ATTRS)

    def initialize(more_info)
      @title = more_info.fetch :title

      @links = []
      more_info.fetch(:links).each do |link_data|
        text = link_data.fetch :text
        properties = [text]

        path = link_data[:path]
        message = link_data[:message]
        raise 'Must have only one of path or message' if path and message

        properties.push(
          if path or message
            path ? path : under_construction_path(message: message)
          else
            under_construction_path(message: text)
          end
        )

        link = Struct.new(:text, :path).new(*properties)

        @links.push link
      end
    end
  end
end
