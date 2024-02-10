# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardComponent, type: :component do
  subject { Capybara.string(render_inline(described_class.new(card: , card_counter: 0))) }

  context "with a normal card (Copper)" do
    let(:game_state) { build(:game_state) }
    let(:card) { GameEngine::BasicCards::Copper.new(game_state) }

    it "renders the wrapping card div with card type (Treasure)" do
      expect(subject).to have_css "div.cell.card.treasure"
    end

    it "renders the card name" do
      expect(subject).to have_css "div.card-name", text: "Copper"
    end

    it "has the card text as title text" do
      expect(subject).to have_css "div.card-name[title='Treasure (cost: 0)\n$1']"
    end

    it "connects the tooltip controller to the card name" do
      expect(subject).to have_css "div.card-name[data-controller='tooltip']"
    end
  end
end
