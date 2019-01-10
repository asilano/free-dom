require 'rails_helper'

RSpec.describe JournalsController, type: :routing do
  describe 'routing' do
    it 'is not visible' do
      expect(get: '/journals').not_to be_routable
      expect(get: '/journals/1').not_to be_routable
    end

    it 'has no forms' do
      expect(get: '/journals/new').not_to be_routable
      expect(get: '/journals/1/edit').not_to be_routable
    end

    it 'routes to #create' do
      expect(post: '/journals').to route_to('journals#create')
    end

    it 'is not modifiable' do
      expect(put: '/journals/1').not_to be_routable
      expect(patch: '/journals/1').not_to be_routable
    end

    it 'routes to #destroy' do
      expect(delete: '/journals/1').to route_to('journals#destroy', id: '1')
    end
  end
end
