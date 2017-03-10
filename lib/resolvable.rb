module Resolvable
  def self.included(base)
    base.extend(ClassMethods)
  end

  def method_missing(sym, *args, &block)
    m = sym.to_s.match(/^resolve_(.*)$/)
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
      res = Resolution.new(symbol, self)
      @resolutions ||= []
      @resolutions << res
      res
    end
  end
end

class Resolution
  attr_reader :name

  def initialize(name, klass)
    @name = name
    @klass = klass
    @validations = []
    @preps = []
  end

  def with(&block)
    @klass.send(:define_method, "resolution_#{@name}_occurs", block)
  end

  def using(template)
    @template = template
    @journal_valdn = JournalMatchValidator.new(@template)
    self
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
    @validations << ParamPresenceValidator.new(@template, arg)
    self
  end

  def validating_param_is_card(*args, &block)
    @validations << ParamCardValidator.new(@template, *args, &block)
    self
  end

  def validating_param_is_card_array(*args, &block)
    @validations << ParamCardArrayValidator.new(@template, *args, &block)
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
    @validations << ParamValueInArrayValidator.new(@template, *args, &block)
    self
  end

  def validating_param_satisfies(*args, &block)
    @validations << ParamValueSatisfiesValidator.new(*args, &block)
    self
  end

  def resolve(card, journal, actor, check: false)
    # Give card access to the necessary resolve arguments
    card.instance_variable_set(:@res_actor, actor)
    card.instance_variable_set(:@res_journal, journal)

    def card.actor; @res_actor; end
    def card.journal; @res_journal; end

    # Run the preparations
    @preps.each { |prep| prep.prepare(card) }

    # Run the special Journal Match validation, and deny ownership if it fails
    if !@journal_valdn.validate(card, journal)
      journal.errors.add(:base, :no_question)
      return false
    end

    if check
      return true
    end

    # Run the validations
    failures = @validations.map do |validation|
      failed = !validation.validate(card, journal)
      journal.errors.add(:base, validation.failure_msg) if failed && validation.failure_msg
      failed
    end

    return true if failures.any?
    card.send("resolution_#{@name}_occurs")
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
    end
  end

  # Validation classes
  class Validator
    include CardsHelper
    attr_reader :failure_msg
  end

  class JournalMatchValidator < Validator
    def initialize(template)
      @template = template
      @failure_msg = "Supplied journal doesn't match expected pattern"
    end

    def validate(card, journal)
      ok = journal =~ @template.to_re
      Rails.logger.info("Expecting: /#{@template.to_re}/; got: '#{journal.event}' Match: #{!ok.nil?}")
      ok
    end
  end

  class ParamPresenceValidator < Validator
    def initialize(template, *keys)
      @template = template
      if keys.last.kind_of? Hash
        @failure_msg = keys.pop[:failure_msg]
      end
      @failure_msg ||= "Invalid parameters - need at least one of #{keys.map(&:inspect).join(', ')}"
      @keys = keys
    end

    def validate(card, journal)
      match = @template.match(journal.event)
      @keys.flatten.each do |k|
        sym = "@#{k}".to_sym
        journal.instance_variable_set(sym, match[k.to_s])
        journal.define_singleton_method(k) { instance_variable_get(sym) }
      end

      @keys.any? do |k|
        if k.kind_of? Array
          k.all? { |kk| match.names.include? kk.to_s }
        else
          match.names.include? k.to_s
        end
      end
    end
  end

  class ParamCardValidator < Validator
    def initialize(template, key, options, &condition)
      raise "Must supply :scope parameter to validating_param_is_card" unless options.has_key? :scope
      @template = template
      @key = key
      @player_key = options[:player]
      @scope = options[:scope]
      @condition = condition
      @failure_msg = options[:failure_msg]
      @custom_message = @failure_msg.present?
    end

    def validate(card, journal)
      match = @template.match(journal.event)
      return true if !match.names.include? @key.to_s
      valid = true
      player = @player_key ? Player.find(match[@player_key]) : card.actor
      candidates = (@scope == :supply) ? player.game.supply_cards : player.cards.send(@scope)
      find_type, test_card = find_card_for_journal(candidates, match[@key])
      if find_type != :ok
        journal.card_error find_type
        valid = false
      end

      if @condition && valid
        @failure_msg = "Invalid parameters - card doesn't satisfy the required conditions" unless @custom_message

        # We need a way for the card under test to examine the state of the resolving card.
        # The following trick is borrowed from squeel.
        test_card.instance_variable_set(:@res_card, card)
        def test_card.my(&block)
          @res_card.instance_eval &block
        end
        valid = test_card.instance_eval &@condition
        if !valid
          journal.errors.add(:base, @failure_msg)
        end
      end

      if valid
        sym = "@#{@key}".to_sym
        journal.instance_variable_set(sym, test_card)
        journal.define_singleton_method(@key) { instance_variable_get(sym) }
      end

      valid
    end
  end

  class ParamCardArrayValidator < Validator
    def initialize(template, key, options, &condition)
      raise "Must supply :scope parameter to validating_param_is_card" unless options.has_key? :scope
      @template = template
      @key = key
      @options = options
      @condition = condition
    end

    def validate(card, journal)
      # We can coerce ParamCardValidator into doing the dirty work for us here.
      match = @template.match(journal.event)
      return true if !match.names.include? @key.to_s

      if @options[:allow_blank_with].andand == match[@key]
        all_valid = true
        card_array = []
      else
        value_hash = {}
        match.names.each { |n| value_hash[n] = match[n] }
        name_array = match[@key].split(',').map(&:strip)
        card_array = []

        if @options[:max_count].is_a? Integer
          if @options[:max_count] < name_array.length
            @failure_msg = "Too many cards specified (more than #{@options[:max_count]})"
            return false
          end
        elsif @options[:max_count].respond_to? :call
          max_count = @options[:max_count].call(card)
          if max_count < name_array.length
            @failure_msg = "Too many cards specified (more than #{@options[:max_count]})"
            return false
          end
        end

        if @options[:count].is_a? Integer
          if @options[:count] != name_array.length
            @failure_msg = "Wrong number of cards specified (should be #{@options[:count]})"
            return false
          end
        elsif @options[:count].respond_to? :call
          count = @options[:count].call(card)
          if count != name_array.length
            @failure_msg = "Wrong number of cards specified (should be #{@options[:count]})"
            return false
          end
        end

        all_valid = name_array.all? do |value|
          # Fill with all fields except @key, then fill @key with just one card. Then call through
          value_hash[@key] = value
          fake_journal = Journal.new(event: @template.fill(value_hash))
          validator = ParamCardValidator.new(@template, "#{@key}", @options, &@condition)
          valid = validator.validate(card, fake_journal)

          @failure_msg = validator.failure_msg unless valid
          fake_journal.errors.each { |attrib, err| journal.errors.add(attrib, err) }
          card_array << fake_journal.send(@key) if valid
          valid
        end
      end

      if all_valid
        sym = "@#{@key}".to_sym
        journal.instance_variable_set(sym, card_array)
        journal.define_singleton_method(@key) { instance_variable_get(sym) }
      end

      all_valid
    end
  end

  class ParamPileValidator < Validator
    def initialize(key, options = {}, &condition)
      @key = key
      @condition = condition
      @failure_msg = options[:failure_msg]
      @allow_empty = options[:allow_empty]
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

      @failure_msg = "Invalid parameters - pile #{index} is empty" if valid && !@custom_message
      test_pile = actor.game.piles[index]
      valid &&= @allow_empty || test_pile.cards.present?

      if @condition && valid
        @failure_msg = "Invalid parameters - pile #{index} doesn't satisfy the required conditions" unless @custom_message

        # We need a way for the card under test to examine the state of the resolving card.
        # The following trick is borrowed from squeel.
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
    def initialize(template, key, *args)
      @template = template
      if args.last.kind_of? Hash
        @failure_message = args.pop[:failure_msg]
      end
      @failure_msg ||= "Invalid parameters - parameter '#{key}' must be one of #{args.join(', ')}"
      @key = key
      @values = args
    end

    def validate(card, journal)
      match = @template.match(journal.event)
      return true if !match.names.include? @key.to_s

      @values.include?(match[@key])
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
