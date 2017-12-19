class CardTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    ok = begin
      value.constantize.superclass == Card
    rescue NameError
      false
    end
    record.errors[attribute] << (options[:message] || 'is not a card type') unless ok
  end
end