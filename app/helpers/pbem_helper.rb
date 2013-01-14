module PbemHelper

  def hidden_line(player, zone, descr)
    ("#{descr}: " + pluralize(player.cards.send(zone).length, "card")).html_safe
  end

  def control_line(player, zone, descr)
    if !player.cards.send(zone).empty?
      "#{descr}: " + player.cards.send(zone).each_with_index.map {|card, ix| "#{ix}. #{card}"}.join(' | ')
    else
      "#{descr}: None"
    end.html_safe
  end

  def public_zone_line(player, zone, descr)
    if !player.cards.send(zone).empty?
      "#{descr}: " + player.cards.send(zone).join(', ')
    else
      "#{descr}: None"
    end.html_safe
  end

  def extra_info(player, *opts)
    info = ""
    if !player.cards.of_type("Seaside::PirateShip").empty?
      info << "Pirate Coins: #{player.state.pirate_coins}\n"
    end
    if player.score != 0
      info << "Score: #{player.score}\n"
    end
    sa_locs = [Seaside::Island, Seaside::Haven]
    sa_locs += [Seaside::NativeVillage] unless opts.include? :public
    sa_locs.each do |kind|
      if !player.cards.of_type(kind.to_s).empty?
        info << "Set Aside with #{kind.to_s}: #{player.cards.in_location(kind.to_s.demodulize.underscore).join(', ')}\n"
      end
    end
    info.html_safe
  end

  def opts_for_buttons_from_valid(control, key, prompt, opts = {})
    opt_str = ""
    if control[key].any?
      opt_str = control[key].each_with_index.map do |valid, ix|
        "'#{prompt} #{ix}'" if valid
      end.compact.join(', ')
      opt_str << " or " if control[:nil_action]
    end
    if control[:nil_action]
      opt_str << "'None' for #{control[:nil_action]}."
    end

    return opt_str.html_safe
  end

  def opts_for_buttons_from_options(control, key, prompt, opts = {})
    opt_str = control[key].map do |opt|
      "'#{prompt} #{opt[:choice]}' for #{opt[:text]}"
    end.join(', ')

    return opt_str.html_safe
  end

end
