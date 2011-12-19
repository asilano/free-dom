class PendingAction < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  acts_as_tree
  
  after_create :email_owner
  
  def before_create
    # If a :text hasn't been specified, set it to the humanized version of the
    # :expected_action string
    self.text ||= expected_action.humanize
  end
  
  def queue(attribs)
    insert_child!(attribs)
  end
  
  def concurrent(att_sets)
    logger.info att_sets.inspect
    att_sets.each {|att| children.create!(att)}
  end
  
protected
  def email_owner
    if player && player.user.pbem?
      Player.to_email[player.id] ||= {}
      Player.to_email[player.id][:game_state] = [:controls, 
                                                 "free-dom: Your action is required: Game '#{game.name}'",
                                                 "You are needed to take one or more actions in '#{game.name}'.",
                                                 nil]
    end
  end
end
