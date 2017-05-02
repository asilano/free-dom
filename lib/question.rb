class Question
  include ActiveModel::Model
  attr_accessor :object, :method, :actor, :text, :params, :strand

  def delete
    @strand.questions.delete(self)
    @strand.check_finished
  end

  def insp
    "<Question: @object=<#{@object.class}:#{@object.object_id}, @player=id:#{@actor.andand.id}, @method=#{@method}, @text='#{text}'>"
  end
end
