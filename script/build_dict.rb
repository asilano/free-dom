File.open("#{Rails.root}/public/javascripts/card_dict.js", "w") do |f|
  f.write("card_dict = ")
  dict = Card.all_card_types.inject({}) {|h, ty| h[ty] = ty.text; h}.to_json
  f.write(dict)  
end