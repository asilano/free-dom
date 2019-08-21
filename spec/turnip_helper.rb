require 'rails_helper'
Dir.glob('spec/steps/**/*.rb') { |f| load f }

RSpec.configure do |config|
  config.include GameSteps
end
