class Question
  include ActiveModel::Model
  attr_accessor :object, :method, :actor, :text
end