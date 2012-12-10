File.open("#{Rails.root}/app/assets/javascripts/card_dict.js", "w") do |f|
  f.write("card_dict = ")
  dict = Card.all_card_types.inject({}) {|h, ty| h[ty] = ty.text; h}.to_json
  f.write(dict)
end

File.open("#{Rails.root}/features/support/card_types.rb", "w") do |f|
  f.write("CARD_TYPES = {")
  str = Card.all_card_types.map {|ty| "\"#{ty.readable_name}\" => #{ty.name}"}.join(",\n")
  f.write(str)
  f.write("}")
end