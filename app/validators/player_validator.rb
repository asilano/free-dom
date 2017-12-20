class PlayerValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || :blank) if value.blank? && !options[:allow_nil]
    player = Game.current.players.where(id: value)

    record.errors[attribute] << (options[:message] || 'is not a player in this game') if player.blank?
  end
end