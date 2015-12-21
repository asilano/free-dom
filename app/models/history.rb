class History
  include ActiveModel::Model
  attr_accessor :event, :css_class, :created_at
  def initialize(attribs={})
    super
    @created_at = Time.now
  end
end
