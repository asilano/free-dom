module GamesHelper
  def to_class(ctype)
    ctype.camelize.constantize
  end

  def running_player_list(game)
    game.players.map do |p|
      str = ""
      str += "<span class='current'>" if p.questions.any?
      str += p.name
      str += "</span>" if p.questions.any?
      str
    end.join(', ')
  end

  def game_buttons_for(game, user)
    html = ''

    user_games = user.andand.games
    if game.state == 'ended'
      # Review button only. Links to Watch or Play depending on whether the user was a player
      review_path = watch_game_path(game)
      if user_games.andand.include?(game)
        review_path = play_game_path(game)
      end

      html = content_tag(:td, link_to('Review', review_path, class: 'button look'))
      html << tag(:td)
    elsif game.state == 'waiting'
      if user_games.andand.include?(game)
        # User already in game. Just give them a Play button
        html = tag(:td) + content_tag(:td, link_to('Play', play_game_path(game), class: 'button play'))
      else
        # User not in game. Give Watch, and Join if not at max players
        html = content_tag(:td, link_to('Watch', watch_game_path(game), class: 'button look', type: nil))
        if game.players.length < game.max_players
          html << content_tag(:td, button_to('Join', join_game_path(game), class: 'play'))
        else
          html << tag(:td)
        end
      end
    elsif game.state == 'running'
      # Game running. Give Watch or Play based on whether user is in game
      if user_games.andand.include? game
        html = tag(:td) + content_tag(:td, link_to('Play', play_game_path(game), class: 'button play'))
      else
        html = content_tag(:td, link_to('Watch', watch_game_path(game), class: 'button look', type: nil)) + tag(:td)
      end
    end

    # Delete button if player is in the game, or is me.
    if (user && (user.name == 'Chowlett' || user.games.include?(game))) # || request.host == '127.0.0.1'
      html << content_tag(:td, button_to('Destroy', game, data: { confirm: 'Are you sure?'}, method: :delete, class: 'danger'))
    end

    html.html_safe
  end

  def format_history(history, player)
    result = history.event
    result.gsub!(/\[([0-9]+)\?([^|]*)\|([^\]]*)\]/) do |match|
      if player and player.id == $1.to_i
        # This history belongs to the current player. Use the full form, captured
        # in group 2
        $2
      else
        # Player doesn't match. Display just the public data.
        $3
      end
    end
    result
  end

  def format_chat(chatline)
    html = ""

    # First, the preamble. Wrapping span for the speaking player.
    html += "<span"
    if chatline.player
      html += " class='fg-player#{chatline.player.seat}'>"
    else
      html += " class='fg-noplayer'>"
    end

    # Speaking player's name, and timestamp
    if chatline.player
      html += chatline.player.name
    else
      html += chatline.non_ply_name
    end
    html += " <span class='turnstamp'>(Turn #{chatline.turn_player ? (chatline.turn_player.name + ':') : ''}#{chatline.turn})</span></span>: "

    # Now the actual text. Style @name callouts
    txt = h chatline.statement
    chatline.game.players.each do |ply|
      txt.gsub!(/(@#{ply.name})/i, "<span class='fg-player#{ply.seat}'>\\1</span>")
    end
    html += txt

    html
  end

  def card_content(card_or_pile, cost = nil)
    inner_content = card_or_pile.readable_name
    if cost
      inner_content += " [#{cost}]"
    end

    if card_or_pile.kind_of?(Card) && card_or_pile.location == 'play' &&
        card_or_pile.player.cards.in_location('prince').of_type('PromoCards::Prince').any? { |p| p.state[:princed_id] == card_or_pile.id }
      inner_content << tag('br') + '(Princed)'
    end
    content_tag(:div, inner_content.html_safe, class: "content") +
      content_tag(:div, nil, :class => "bg left") +
      content_tag(:div, nil, :class => "bg right")
  end

  def pile_state(pile)
    return "" if pile.state.nil?
    strs = pile.state.map do |key, value|
      case key
      when :embargo
        "Embargoed: #{value}"
      when :contraband
        "Contraband" if value
      when :trade_route_token
        "&#9673; Trade Route" if value
      end
    end.compact

    return strs.map { |state| "<div class='fact'>#{state}</div>" }.join()
  end

  def pile_class(pile)
    if pile.game.state == 'waiting'
      'one-card'
    elsif pile.cards.empty?
      'emptyPile'
    else
      case pile.cards.count
      when 1
        'one-card'
      when 2
        'two-cards'
      when 3..5
        'few-cards'
      when 6..Float::INFINITY
        'many-cards'
      end
    end
  end

  def game_facts(game)
    facts = ""

    if game.facts[:trade_route_value]
      facts += "<li><span class='title'>Trade Route:</span> #{game.facts[:trade_route_value]} cash</li>"
    end

    if !facts.empty?
      facts = "<div id='gameFacts'><ul>#{facts}</ul></div>"
    end

    facts
  end

  def set_aside_area(player, public = true)
    public_card_types = [Seaside::Island, PromoCards::Prince]
    private_card_types = [Seaside::Haven, Seaside::NativeVillage]

    all_card_types = public_card_types + private_card_types
    card_types = public_card_types + (public ? [] : private_card_types)

    if player.cards.of_type(*all_card_types.map{|t| t.to_s}).empty?
      return ""
    end

    html_string = ""
    card_types.each do |type|
      if !player.cards.of_type(type.to_s).empty?
        html_string += "<tr><th>#{type.readable_name}:</th>"
        html_string += "<td>"
        cards = player.cards.in_location(type.to_s.demodulize.underscore)
        if !cards.empty?
          html_string += "<div class='full_cards'>"
          html_string += render(:partial => 'card_with_ctrls', :collection => zip_cards_no_ctrls(cards))
          html_string += "</div>"
        else
         html_string +=  "None"
        end
        html_string += "</td></tr>"
      end
    end

    if public
      private_card_types.each do |type|
        if !player.cards.of_type(type.to_s).empty?
          html_string += "<tr><th>#{type.readable_name}:</th>"
          html_string += "<td>#{player.cards.in_location(type.to_s.demodulize.underscore).count}</td>"
          html_string += "</tr>"
        end
      end
    end
    return html_string
  end

  def forge_calc(control)
    scr = <<EOS
      elems = $('[name=#{control[:name]}\\\\[\\\\]]');
      sum = 0;
      elems.each(function()
      {
        if ($(this).is('[id^=#{control.object_id}_]:checked'))
        {
          sum += parseInt($(this).data('js'));
        }
      });

      $('##{control.object_id.to_s}_js').text('Total: ' + sum);
EOS
    return scr
  end

  def setting_checkbox(name, label)
    str = hidden_field_tag("settings[#{name}]", 0)
    str << check_box_tag(name, 1, @player.settings.__send__(name), name: "settings[#{name}]", class: 'toggle-checkbox')
    str << label_tag(name, label, class: 'setting-label')
    str << label_tag(name, tag(:span, class: 'toggle-feature', data: {label_on: 'on', label_off: 'off'}), class: 'toggle-btn')
    content_tag(:div, str, class: 'game-setting toggle-setting')
  end

  def setting_dropdown(name, label, options)
    str = select_tag(name, options_for_select(options, @player.settings.__send__(name)), :name => "settings[#{name}]")
    str << label_tag(name, label, class: 'setting-label')
    content_tag(:div, str, class: 'game-setting select-setting')
  end

  def control_form(control)
    str = ''
    if control[:if_empty]
      control[:if_empty].each do |key, value|
        str << raw(hidden_field_tag("journal[if_empty][#{key}]", value, :id => "#{key}_#{control[:name]}_#{control.object_id}"))
      end
    end

    form = form_for(Journal.new,
                    html: {
                      :remote => true,
                      :id => "form_#{control.object_id}",
                      :class => 'ajaxSpinSmall'
                    }) do |f|
      f.hidden_field(:type, value: control[:journal_type]) + raw(str)
    end

    content_for(:control_forms, raw(form))
  end

  # Convert an array of cards and an array of control-hashes into an array of pairs,
  # each being a card and an array of the control-hashes affecting that card.
  def zip_cards_and_ctrls(cards, controls)
    # Create a template return array
    rtn = cards.zip(Array.new(cards.length) { [] })
    controls.each do |ctrl|
      Rails.logger.info(ctrl.inspect)
      parameters = ctrl.delete(:parameters)
      rtn.zip(parameters) do |pair, param|
        pair[1] << [param, ctrl]
      end
    end

    rtn
  end

  def zip_cards_no_ctrls(cards)
    zip_cards_and_ctrls(cards, [])
  end

  def classes_for_journal(journal, player)
    classes = []
    classes << 'error' if journal.errors.any?
    if journal.player
      classes << "player#{journal.player.seat}" if journal.player.seat
      classes << 'self' if player == journal.player
      classes << journal.css_class.split if journal.css_class
    end
    classes
  end

  def control_validation(control)
    str = ''
    control[:validate].andand.each do |condition, value|
      case control[:type]
      when :checkboxes
        case condition
        when :max_count
          str << javascript_tag(<<JS
function vald_#{control.object_id}_max_count() {
  var count = $('input:checkbox[name="journal[#{control[:field_name]}][]"][form="form_#{control.object_id}"]:checked').length;
  if (count > #{value}) {
    $('button[name="journal[template]"][type="submit"][form="form_#{control.object_id}"]').prop('disabled', true);
  }
  else {
    $('button[name="journal[template]"][type="submit"][form="form_#{control.object_id}"]').prop('disabled', false);
  }
}

$('input:checkbox[name="journal[#{control[:field_name]}][]"][form="form_#{control.object_id}"]').bind('click', vald_#{control.object_id}_max_count);
vald_#{control.object_id}_max_count();
JS
)
        end
      end
    end

    raw str
  end
end
