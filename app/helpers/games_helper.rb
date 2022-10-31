require 'random_namer'
module GamesHelper
  def random_game_name
    RandomNamer::random_name
  end

  def run_state_button_class(state)
    case state
    in :waiting
      "warning"
    in :running
      "success"
    in :ended
      "primary"
    end
  end

  def run_state_icon_class(state)
    case state
    in :waiting
      "fa-pause"
    in :running
      "fa-play"
    in :ended
      "fa-eject"
    end
  end
end
