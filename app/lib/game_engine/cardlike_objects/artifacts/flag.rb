module GameEngine
  module CardlikeObjects
    module Artifacts
      class Flag < Artifact
        comes_from Renaissance::FlagBearer
        text "When drawing your hand, +1 Card"
      end
    end
  end
end
