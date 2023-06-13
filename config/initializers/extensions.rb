class Module
  def readable_name
    name.demodulize.underscore.titleize
  end

  # Return a list of card classes within this module - that is, module constants
  # which are classes, and whose superclass is Card
  def card_classes
    constants.map { |name| const_get name }.select { |c| c < GameEngine::Card }
  end

  def kingdom_cards
    model_files = Dir.glob("#{Rails.root}/app/lib/#{name.underscore}/*.rb")
    model_names = model_files.map { |fn| File.basename(fn, ".rb").camelize }
    model_names.map { |mn| "#{name}::#{mn}".constantize }.sort_by { |c| [c.try(:raw_cost), c.readable_name] }
  end
end

class String
  def integer?(allow_negative: false)
    self =~ /\A#{'-?' if allow_negative}\d+\z/
  end
end

module Enumerable
  def take_until
    ary = []
    each do |elem|
      ary << elem
      break if yield elem, ary
    end
    ary
  end
end
