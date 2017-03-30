# ... edited by app gen (product resource)

require 'rails_helper'

RSpec.describe ProductsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/products').to route_to('products#index')
    end

    it 'routes to #show' do
      expect(get: '/products/1').to route_to('products#show', id: '1')
    end

    # ...
    it 'routes to #buy' do
      expect(post: '/products/buy').to route_to('products#buy')
    end
  end
end
