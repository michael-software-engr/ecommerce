# edited by app gen (landing page)

class LandingPageController < ApplicationController
  layout 'landing_page'

  def index
    @services = [
      {
        name: 'Example Service 1',
        description: 'Brief service description. This service does X.',
        price: 12.99,
        icon: 'cloud',

        image: 'theme/modals/cabin.png',
        more_info: <<~EOT
          Longer service description.
          Filler text follows:
          Intuitive composite standardization.
          Adaptive 6th generation migration.
          Face to face multi-state moderator.
          Devolved impactful portal.
          Customer-focused object-oriented frame.
        EOT
      },
      {
        name: 'Example Service 2',
        description: 'Brief service description. This service does Y.',
        price: 34.59,
        icon: 'compass',

        image: 'theme/modals/submarine.png',
        more_info: <<~EOT
          Longer service description.
          Filler text follows:
          Networked multi-tasking data-warehouse.
          Horizontal content-based conglomeration.
          Realigned leading edge orchestration.
          Vision-oriented multi-state contingency.
          Utilize revolutionary mindshare.
        EOT
      },
      {
        name: 'Example Service 3',
        description: 'Brief service description. This service does Z.',
        price: 84.20,
        icon: 'flask',

        image: 'theme/modals/cake.png',
        more_info: <<~EOT
          Longer service description.
          Filler text follows:
          Front-line upward-trending pricing structure.
          Reduced disintermediate function.
          Business-focused discrete Graphic Interface.
          Innovative motivating policy.
          Digitized systemic hierarchy.
          User-centric disintermediate solution.
        EOT
      },
      {
        name: 'Example Service 4',
        description: 'Brief service description. This service does X, Y and Z.',
        price: 120.05,
        icon: 'shield',

        image: 'theme/modals/safe.png',
        more_info: <<~EOT
          Longer service description.
          Filler text follows:

          Digitized executive model.
          Down-sized analyzing adapter.
          Front-line incremental capacity.
          Balanced fault-tolerant data-warehouse.
          Visionary regional budgetary management.
        EOT
      }
    ].map.with_index { |service, ix| SubscriptionService.new service, ix }
  end
end

class SubscriptionService
  include Rails.application.routes.url_helpers

  ATTRS = %i[
    name description price subscribe_path more_info_path icon
    image more_info
    index
  ].freeze

  private_constant :ATTRS

  attr_reader(*ATTRS)

  def initialize(service, index)
    service.each do |key, value|
      raise "Invalid key '#{key}', #{ATTRS}" if !ATTRS.include? key
      instance_variable_set("@#{key}", value)
    end

    @subscribe_path = under_construction_path(
      message: "Subscribe to service # #{index}"
    )

    @more_info_path = "#modal#{index}"
    @index = index
  end
end
