class Journal < ApplicationRecord
  belongs_to :game
  belongs_to :user, optional: true

  validates :order, uniqueness: { scope: [:fiber_id, :game_id] }

  attr_reader :histories
  attr_accessor :auto, :question
  attr_accessor :ignore # Used for tests

  delegate :opts, to: :question

  # Nested classes let GameEngine request the right journal at the right time
  class Template
    include JournalsHelper::Validations

    attr_reader :opts, :player, :game

    def initialize(player, game)
      @player = player
      @game = game
    end

    def with(opts)
      @opts = opts
      self
    end

    def question
      @question ||= self.class::Question.new(self, @player, @opts)
    end

    def matches?(journal)
      journal.is_a? self.class.module_parent
    end

    def valid?(journal)
      define_singleton_method(:journal) { journal }
      return false unless journal.skip_owner_check || player == journal.player
      do_validate
    end

    def do_validate
      true
    end

    class Question
      include ActionView::Helpers::TextHelper

      attr_reader :template, :opts, :player
      attr_accessor :fiber_id, :auto_candidate
      def initialize(template, player, opts)
        @template = template
        @opts = opts
        @player = player
        @fiber_id = nil
      end

      def journal_type
        self.class.module_parents.detect { |klass| klass < Journal }
      end

      def card_type
        self.class.module_parents.detect { |klass| klass < GameEngine::Card }
      end

      def controls_for(user, game_state)
        get_controls(game_state).each { |ctrl| ctrl.fiber_id = @fiber_id }
                                .select { |ctrl| ctrl.player.user == user }
      end

      def self.prevent_auto
        define_method(:can_be_auto_answered?) { |_| false }
        self
      end

      def self.with_controls(&controls)
        define_method(:get_controls, &controls)
      end

      def can_be_auto_answered?(game_state)
        return false unless @player

        # A question can be skipped over with an autoanswer if:
        # * it's a question for someone other than the "spawner"
        # * the question has only one possible answer
        return false unless @auto_candidate

        controls = controls_for(@player.user, game_state)
        controls.length == 1 && controls.first.single_answer?(game_state)
      end

      def auto_answer(game_state)
        return nil unless can_be_auto_answered?(game_state)

        control = controls_for(@player.user, game_state).first
        game_state.game.journals.create(
          type:     journal_type,
          user:     @player.user,
          order:    (game_state.game.journals.maximum(:order) || 0) + 1,
          fiber_id: @fiber_id,
          params:   { control.key => control.single_answer }
        )
      end

      def to_s
        "#{self.class} for #{@player.name} (#{@opts}) - Game is #{@template.game.class}"
      end

      private

      def get_controls(_game_state)
        []
      end
    end
  end

  # When a Journal subclass is created, give that subclass its own
  # nested Template and Question classes
  def self.inherited(subclass)
    super
    subclass.const_set('Template', Class.new(Template))
  end

  def self.define_question(text = nil, &block)
    raise ArgumentError, 'Supply exactly one of fixed text or text block' unless text.nil? == block_given?
    self::Template.const_set('Question', Class.new(Template::Question))
    if text
      self::Template::Question.define_method(:text) { |_| text }
    else
      self::Template::Question.define_method(:text, &block)
    end
    self::Template::Question
  end

  class TemplateFactory
    def initialize(player, template_class)
      @player = player
      @template_class = template_class
    end

    def in(game)
      @template_class.new(@player, game)
    end
  end
  def self.from(player)
    TemplateFactory.new(player, self::Template)
  end

  def self.validation(&block)
    self::Template.define_method(:do_validate, &block)
  end

  def self.expected_order(fiber_id, game)
    earlier_journals = if fiber_id
                         game.journals
                             .select(:fiber_id, :order)
                             .reject do |other|
                               next false if other.fiber_id.nil?

                               # Ignore fibers which are unrelated to this one
                               # That is, ignore fibers which are neither prefixes
                               # nor suffixes of this one.
                               !GameEngine::FiberWrapper.fibers_related(fiber_id, other.fiber_id)
                             end
                       else
                         game.journals
                       end

    (earlier_journals.map(&:order).max || 0) + 1
  end

  def skip_owner_check
    false
  end
  def self.skip_owner_check
    define_method(:skip_owner_check) { true }
  end

  def self.process(&block)
    define_method(:do_process, &block)
  end

  def game_state
    game.game_state
  end
  delegate :observe, to: :game_state

  def player
    game_state.player_for(user)
  end

  def process(state)
    @histories = []
    game.push_journal(self)
    result = do_process(state)
    game.pop_journal
    result
  end

  def prevent_undo
    game.fix_journal(journal: self)
  end

  def fixed_for_user(for_user)
    return true if for_user != user

    game.fiber_last_fixed_journal_orders
        .keys
        .select { |fid| GameEngine::FiberWrapper.fibers_related(fid, fiber_id) }
        .all? { |fid| order <= game.fiber_last_fixed_journal_orders[fid] }
  end

  def format_for_discord
    return unless persisted?

    if histories.present?
      unless histories.first.secret?
        histories.map { |hist| ApplicationController.helpers.display_event_for_public(hist.event) }
                 .join("\n - ")
      end
    else
      "#{user&.name || 'The game'}'s choice for '#{self.class.from(user).in(game).question.text(game_state)}', which is now invalid"
    end
  end
end
