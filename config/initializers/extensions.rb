# Add a method to Object, that reverses the sense of include?
class Object
  def in?(enum)
    raise TypeError, "expected Enumerable parameter" unless enum.is_a? Enumerable
    enum.include? self
  end
end

class String
  def readable_name
    demodulize.underscore.titleize
  end
end

class Module
  # Return a list of card classes within this module - that is, module constants
  # which are classes, and whose superclass is Card
  def card_classes
    model_files = Dir.glob("#{Rails.root}/app/models/#{name.underscore}/*.rb")
    model_names = model_files.map {|fn| File.basename(fn,'.rb').classify}
    model_names.map {|mn| "#{name}::#{mn}".constantize}.sort_by {|c| [c.cost, c.readable_name]}
  end

  alias :kingdom_cards :card_classes

  # Return whether a given class implements (ie overrides) an instance method
  def implements_instance_method?(method_name)
    instance_method(method_name).owner == self
    rescue NameError
    false
  end
end

module Prosperity
  def self.kingdom_cards
    self.card_classes - [Prosperity::Colony, Prosperity::Platinum]
  end
end
