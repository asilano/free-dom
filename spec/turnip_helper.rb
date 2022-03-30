require 'rails_helper'

CARD_NAMES = CARD_TYPES.keys
SINGLE_CARD_NO_CAPTURE = /#{CARD_NAMES.join('|')}/
SINGLE_CARD = /(#{SINGLE_CARD_NO_CAPTURE})/
CARD_LIST_NO_REP =
  / (
      (?:
        (?:#{CARD_NAMES.join('|').gsub(/ /, '\ ')})
        (?:,\ )?
      )+
    )/x
CARD_LIST_NO_CAPTURE =
  / (?:
      (?:#{CARD_NAMES.join('|').gsub(/ /, '\ ')}) # Any Card Name
      (?:\ ?x\ ?\d+)?                             # Repeated "x 10"
      (?:,\ )?                                    # Optional comma separator
    )+
  /x
CARD_LIST = /(#{CARD_LIST_NO_CAPTURE})/
# NamedRandCards = /(\d+) (?:other )?cards?(?: named "(.*)")?/
# NamedRandCardsNoMatch = /\d+ (?:other ?cards?(?: named ".*")?/

ARTIFACT_NAMES = ARTIFACT_TYPES.keys
ARTIFACT_NO_CAPTURE = /#{ARTIFACT_NAMES.join("|")}/
ARTIFACT = /(#{ARTIFACT_NO_CAPTURE})/

Dir.glob('spec/steps/**/*.rb') { |f| load f }

RSpec.configure do |config|
  config.include GameSteps
end
