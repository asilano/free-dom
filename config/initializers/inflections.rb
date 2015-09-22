# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )

    # Cards with names in the plural need to be inflected as uncountable
    plural_cards = Dir.glob("#{Rails.root}/app/models/*/*s.rb").map{|fn| File.basename(fn, '.rb')}
    inflect.uncountable plural_cards
    inflect.uncountable 'militia'
    inflect.plural /^talisman$/, 'talismans'
    inflect.plural /^oasis$/, 'oases'
    inflect.plural /^jack of all trades$/, 'jacks of all trades'
end
