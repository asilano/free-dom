class CardValidator < ActiveModel::EachValidator
  include CardsHelper

  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || :blank) if value.blank? && !options[:allow_nil]
# Haven't processed journals yet
    card = Game.current.find_card(value)

    unless card
      record.errors[attribute] << (options[:message] || 'is not a card ID')
      return
    end

    if options[:owner]
      owner = record.actor if options[:owner] == :actor
    end

    record.errors[attribute] << (options[:message] || "is not owned by #{owner}") if owner && card.player != owner
    record.errors[attribute] << (options[:message] || "is not in #{options[:location]}") if options[:location] && card.location != options[:location].to_s

    if options[:location] == 'pile'
      record.errors[attribute] << (options[:message] || "is not on top of its pile") unless card.position == 0
    end

    satisfied = true
    case options[:satisfies]
    when Proc
      satisfied = options[:satisfies].call(card, record.record)
    when Symbol
      satisfied = card.send(options[:satisfies])
    end
    record.errors[attribute] << (options[:satisfy_msg] || options[:message] || "does not satisfy condition") unless satisfied
  end
end