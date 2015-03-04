module Resolvable
  def self.included(base)
    base.extend(ClassMethods)
  end

  def method_missing(sym, *args, &block)
    m = sym.to_s.match /^resolve_(.*)$/
    if m && self.class.resolutions.present?
      name = m[1]
      resolution = self.class.resolutions.detect { |r| r.name == name.to_sym }
      return resolution.resolve(self, *args) if resolution
    end

    super
  end

  def respond_to_missing?(sym, include_priv)
    rc = super

    m = sym.to_s.match /^resolve_(.*)$/
    if !rc && m && self.class.resolutions.present?
      name = m[1]
      rc = self.class.resolutions.any? { |r| r.name == name.to_sym }
    end

    rc
  end

  module ClassMethods
    attr_reader :resolutions

    def resolves(symbol)
      res = Resolution.new(symbol)
      @resolutions ||= []
      @resolutions << res
      res
    end
  end
end

class Resolution
  attr_reader :name

  def initialize(name)
    @name = name
    @block = nil
    @validations = []
    @preps = []
  end

  def with(&block)
    @block = block
  end

  def prepare_param(*args, &block)
    @preps << ParamPreparator.new(*args, &block)
    self
  end

  def validating_params_has_any_of(*args)
    @validations << ParamPresenceValidator.new(*args)
    self
  end

  def validating_params_has(arg)
    @validations << ParamPresenceValidator.new(arg)
    self
  end

  def validating_param_is_card(*args, &block)
    @validations << ParamCardValidator.new(*args, &block)
    self
  end

  def validating_param_is_card_array(*args, &block)
    @validations << ParamCardArrayValidator.new(*args, &block)
    self
  end

  def validating_param_is_pile(*args, &block)
    @validations << ParamPileValidator.new(*args, &block)
    self
  end

  def validating_param_is_player(*args, &block)
    @validations << ParamPlayerValidator.new(*args, &block)
    self
  end

  def validating_param_present_only_if(*args, &block)
    @validations << ParamOnlyPresentIfValidator.new(*args, &block)
    self
  end

  def validating_param_value_in(*args, &block)
    @validations << ParamValueInArrayValidator.new(*args, &block)
    self
  end

  def validating_param_satisfies(*args, &block)
    @validations << ParamValueSatisfiesValidator.new(*args, &block)
    self
  end

  def resolve(card, actor, params, parent_act)
    # Give card access to the necessary resolve arguments
    card.instance_variable_set(:@res_actor, actor)
    card.instance_variable_set(:@res_params, params)
    card.instance_variable_set(:@res_parent_act, parent_act)

    def card.actor; @res_actor; end
    def card.params; @res_params; end
    def card.parent_act; @res_parent_act; end

    # Run the preparations
    @preps.each { |prep| prep.prepare(card) }

    # Run the validations
    failure_messages = @validations.map do |validation|
      validation.failure_msg unless validation.validate(card)
    end.compact
Rails.logger.info("Errors: #{failure_messages}")
    return failure_messages.join("\n") if failure_messages.present?

    card.define_singleton_method(:resolution_occurs, @block)
    rc = card.resolution_occurs
    card.singleton_class.send(:remove_method, :resolution_occurs)
    rc
  end

  # Preparation class. Pretty simple - it's just a way of delay-running a block
  class ParamPreparator
    def initialize(key, &block)
      @key = key
      raise ArgumentError.new("Expected a block argument to prepare_param") unless block_given?
      @block = block
    end

    def prepare(card)
      # Quick exit if the parameters don't have the specified key
      return true if !card.params.has_key?(@key)

      # Otherwise, run the block.
      card.instance_exec(card.params[@key], &@block)
      Rails.logger.info("Params now: #{card.params}")
    end
  end

  # Validation classes
  class Validator
    attr_reader :failure_msg
  end

  class ParamPresenceValidator < Validator
    def initialize(*keys)
      if keys.last.kind_of? Hash
        @failure_msg = keys.pop[:failure_msg]
      end
      @failure_msg ||= "Invalid parameters - need at least one of #{keys.map(&:inspect).join(', ')}"
      @keys = keys
    end

    def validate(card)
      @keys.any? do |k|
        if k.kind_of? Array
          k.all? { |kk| card.params.has_key? kk }
        else
          card.params.has_key? k
        end
      end
    end
  end

  class ParamCardValidator < Validator
    def initialize(key, options, &condition)
      raise "Must supply :scope parameter to validating_param_is_card" unless options.has_key? :scope
      @key = key
      @player_key = options[:player]
      @scope = options[:scope]
      @condition = condition
      @failure_msg = options[:failure_msg]
      @custom_message = @failure_msg.present?
    end

    def validate(card)
      params = card.params
      return true if !params.has_key? @key
      valid = true

      player = @player_key ? Player.find(params[@player_key]) : card.actor
      # Set failure message according to the test we're about to perform
      @failure_msg = "Invalid parameters - #{@key} is not an integer" unless @custom_message
      index = nil
      begin
        index = params[@key].to_i
      rescue
        valid = false
      end

      @failure_msg = "Invalid parameters - #{@key} #{index} is out of range for #{@scope} cards" if valid && !@custom_message
      valid &&= index >= 0
      valid &&= index < player.cards.send(@scope).count

      if @condition && valid
        @failure_msg = "Invalid parameters - #{@scope} card #{index} doesn't satisfy the required conditions" unless @custom_message

        # We need a way for the card under test to examine the state of the resolving card.
        # The following trick is borrowed from squeel.
        test_card = player.cards.send(@scope)[index]
        test_card.instance_variable_set(:@res_card, card)
        def test_card.my(&block)
          @res_card.instance_eval &block
        end
        valid = test_card.instance_eval &@condition
      end

      valid
    end
  end

  class ParamCardArrayValidator < Validator
    def initialize(key, options, &condition)
      raise "Must supply :scope parameter to validating_param_is_card" unless options.has_key? :scope
      @key = key
      @options = options
      @condition = condition
    end

    def validate(card)
      # We can coerce ParamCardValidator into doing the dirty work for us here.
      return true if !card.params.has_key? @key
      card.params[@key].map.with_index do |value, index|
        card.params["#{@key}_value_##{index}"] = value
        validator = ParamCardValidator.new("#{@key}_value_##{index}", @options, &@condition)
        valid = validator.validate(card)
        @failure_msg = validator.failure_msg unless valid
        valid
      end.all?
    end
  end

  class ParamPileValidator < Validator
    def initialize(key, options = {}, &condition)
      @key = key
      @condition = condition
      @failure_msg = options[:failure_msg]
      @custom_message = @failure_msg.present?
    end

    def validate(card)
      actor = card.actor
      params = card.params
      return true if !params.has_key? @key
      valid = true

      # Set failure message according to the test we're about to perform
      @failure_msg = "Invalid parameters - #{@key} is not an integer" unless @custom_message
      index = nil
      begin
        index = params[@key].to_i
      rescue
        valid = false
      end

      @failure_msg = "Invalid parameters - #{@key} #{index} is out of range for piles" if valid && !@custom_message
      valid &&= index >= 0
      valid &&= index < actor.game.piles.count

      if @condition && valid
        @failure_msg = "Invalid parameters - pile #{index} doesn't satisfy the required conditions" unless @custom_message

        # We need a way for the card under test to examine the state of the resolving card.
        # The following trick is borrowed from squeel.
        test_pile = actor.game.piles[index]
        test_pile.instance_variable_set(:@res_card, card)
        def test_pile.my(&block)
          @res_card.instance_eval &block
        end
        valid = test_pile.instance_eval &@condition
      end

      valid
    end
  end

  class ParamOnlyPresentIfValidator < Validator
    def initialize(key, options = {}, &condition)
      @key = key
      raise ArgumentError.new("Expected a block argument to validating_param_present_only_if") unless block_given?
      @condition = condition
      condition_descr = options[:description]
      @failure_msg = options[:failure_msg] || "Invalid parameters - can't supply #{key} unless #{condition_descr || 'it meets the supplied condition'}"
    end

    def validate(card)
      return true unless card.params.has_key? @key
      card.instance_eval(&@condition)
    end
  end

  class ParamValueInArrayValidator < Validator
    def initialize(key, *args)
      if args.last.kind_of? Hash
        @failure_message = args.pop[:failure_msg]
      end
      @failure_msg ||= "Invalid parameters - parameter '#{key}' must be one of #{args.join(', ')}"
      @key = key
      @values = args
    end

    def validate(card)
      return true unless card.params.has_key? @key
      @values.include?(card.params[@key])
    end
  end

  class ParamPlayerValidator < Validator
    def initialize(key, options = {})
      @key = key
      @failure_msg = options[:failure_msg] || "Invalid parameters - #{key} should be the ID of a player in this game"
    end

    def validate(card)
      return true if !card.params.has_key? @key
      valid = card.game.players.where { id == my{card.params[@key]}.to_i }.count != 0
    end
  end

  class ParamValueSatisfiesValidator < Validator
    def initialize(key, options = {}, &condition)
      @key = key
      raise ArgumentError.new("Expected a block argument to validating_param_satisfies") unless block_given?
      @condition = condition
      riase ArgumentError.new("Expected a block with arity 1 or 2 to validating_param_satisfies") unless [1,2].include?(@condition.arity)
      condition_descr = options[:description]
      @failure_msg = options[:failure_msg] || "Invalid parameters - #{key} must #{condition_descr || 'meet the supplied condition'}"
    end

    def validate(card)
      return true unless card.params.has_key?(@key)

      if @condition.arity == 1
        card.params[@key].instance_eval(&@condition)
      else
        @condition.call(card.params[@key], card)
      end
    end
  end
end
