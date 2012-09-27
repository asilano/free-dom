module GamesHelper
  def to_class(ctype)
    ctype.camelize.constantize
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

    return strs.join('; ')
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
    public_card_types = [Seaside::Island]
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
          html_string += "<table class='hand'>"
          cards.in_groups_of(5) do |chunk|
            html_string += "<tr>"
            html_string += render(:partial => 'card', :collection => chunk.compact)
            html_string += "</tr>"
          end
          html_string += "</table>"
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
    str = check_box_tag name, 1, @player.settings.__send__(name)
    str << label_tag(name, label)
  end

  def control_form(control)
    str = ''
    if control[:params]
      control[:params].each do |key, value|
        str << raw(hidden_field_tag(key, value, :id => "#{key}_#{control[:name]}_#{control.object_id}"))
      end
    end

    form = form_tag({:action => control[:action]},
                        :remote => true,
                        :id => "form_#{control.object_id}",
                        :class => 'ajaxSpinSmall') do
      raw(str)
    end

    content_for(:control_forms, raw(form))
  end
end
