# Border Guards you play reveal 3 cards and discard 2. (It takes all 3 being Actions to take the Horn.)
module GameEngine
  module CardlikeObjects
    class Lantern < Artifact
      comes_from Renaissance::BorderGuard
      text "Border Guards you play reveal 3 cards and discard 2. (It takes all 3 being Actions to take the Horn.)"
    end
  end
end
