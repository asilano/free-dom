require 'pp'
CARD_NAMES = CARD_TYPES.keys
SingleCardNoCapture = /#{CARD_NAMES.join('|')}/
SingleCard = /(#{SingleCardNoCapture})/
CardListNoRep =
/ (
    (?:
      (?:#{CARD_NAMES.join('|').gsub(/ /, '\ ')})
      (?:,\ )?
    )*
  )/x
CardListNoCapture =
/ (?:
    (?:#{CARD_NAMES.join('|').gsub(/ /, '\ ')}) # Any Card Name
    (?:\ ?x\ ?\d+)?                             # Repeated "x 10"
    (?:,\ )?                                    # Optional comma separator
  )*
/x
CardList = /(#{CardListNoCapture})/
NamedRandCards = /(\d+) (?:other )?cards?(?: named "(.*)")?/
NamedRandCardsNoMatch = /\d+ (?:other )?cards?(?: named ".*")?/
