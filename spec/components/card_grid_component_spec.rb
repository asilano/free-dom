# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardGridComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(cards: , controls:)) }
  subject { Capybara.string(rendered) }

  context "with an empty card collection" do
    let(:cards) { [] }

    context "and no controls" do
      let(:controls) { [] }

      it "renders a placeholder empty card-grid" do
        expect(subject).to have_css ".card-grid .cell.card.no-card"
      end
    end

    context "and a control without a no-card control" do
      let(:controls) { [build(:one_card_control)] }

      it "renders a placeholder empty card-grid" do
        expect(subject).to have_css ".card-grid .cell.card.no-card"
      end
    end

    context "and a control with a no-card control" do
      let(:controls) { [build(:one_card_control, :with_no_card_control)] }

      it "renders the no-card control" do
        expect(subject).to have_css ".card-grid .null-card .card-ctrl button", text: "No card"
      end
    end
  end

  context "with a card collection" do
    let(:game_state) { build(:game_state) }
    let(:cards) { [GameEngine::BasicCards::Copper.new(game_state), GameEngine::BasicCards::Estate.new(game_state)] }

    context "and no controls" do
      let(:controls) { [] }

      it "renders the cards" do
        expect(subject).to have_css ".card-grid .card:nth-child(1)", text: "Copper"
        expect(subject).to have_css ".card-grid .card:nth-child(2)", text: "Estate"
      end
    end

    context "and a control without a no-card control" do
      let(:controls) { [build(:one_card_control)] }

      it "renders the cards' controls" do
        puts rendered
        expect(subject).to have_css ".card-grid .card:nth-child(1) button", text: "Choose"
        expect(subject).to have_css ".card-grid .card:nth-child(2) button", text: "Choose"
      end
    end

    context "and a control with a no-card control" do
      let(:controls) { [build(:one_card_control, :with_no_card_control)] }

      it "renders the no-card control" do
        expect(subject).to have_css ".card-grid .null-card .card-ctrl button", text: "No card"
      end
    end
  end
end
