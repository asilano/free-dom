module CardDecorators
  module AttackDecorators
    # Get the attack card to handle attacking each of the victims.
    # All the attacks should be in parallel (unless there's a reason they can't)
    # ...but we'll ignore that for a moment.
    def launch_attack(victims:)
      victims.each { |v| attack(victim: v) }
    end
  end
end
