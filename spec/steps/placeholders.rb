placeholder :count do
  match /\d+/ do |count|
    count.to_i
  end

  match(/^an?$/) { 1 }

  match(/^no$/) { 0 }
end

placeholder :cards do
  match CARD_LIST_NO_CAPTURE do |card_list|
    card_list.split(/,\s*/).flat_map do |kind|
      num = 1
      card_name = kind
      if /(.*) ?x ?(\d+)/ =~ kind
        card_name = $1.rstrip
        num = $2.to_i
      end

      [CARD_TYPES[card_name]] * num
    end
  end

  match /^nothing$/ do
    []
  end

  default do |val|
    # Other values have no meaning without a scope. Just pass it back
    val
  end
end

placeholder :whether_to do
  match /should not/ do
    false
  end

  match /should/ do
    true
  end
end

placeholder :player_name do
  match /([a-zA-Z]+)('s)?/ do |name|
    name == 'my' ? 'I' : name
  end
end
