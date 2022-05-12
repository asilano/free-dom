require "rails_helper"

RSpec.describe GameEngine::ChooseKingdomJournal do
  describe "validity" do
    it "should be valid as basic" do
      journal = FactoryBot.build(:kingdom_journal)
      expect(journal).to be_valid
    end

    it "should be valid with randomiser card_shapeds after 10th" do
      journal = FactoryBot.build(:kingdom_journal)
      journal.params["card_list"][10] = "GameEngine::CardShapedThings::Projects::Cathedral"
      expect(journal).to be_valid
    end
  end

  describe "validation errors" do
    it "should be invalid if card_list param is not an array" do
      journal = FactoryBot.build(:kingdom_journal, params: { "card_list" => :foo })
      expect(journal).to_not be_valid
    end

    it "should be invalid if card_list param is not an array" do
      journal = FactoryBot.build(:kingdom_journal, params: { "card_list" => :foo })
      expect(journal).to_not be_valid
    end

    it "should be invalid if cards are duplicated" do
      journal = FactoryBot.build(:kingdom_journal)
      journal.params["card_list"][0] = journal.params["card_list"][1]
      expect(journal).to_not be_valid
    end

    it "should be invalid if fewer than cards are supplied" do
      journal = FactoryBot.build(:kingdom_journal)
      journal.params["card_list"].pop
      expect(journal).to_not be_valid
    end

    it "should be invalid if the first 10 cards are not Cards" do
      journal = FactoryBot.build(:kingdom_journal)
      journal.params["card_list"][9] = "GameEngine::CardShapedThings::Projects::Cathedral"
      expect(journal).to_not be_valid
    end

    it "should be invalid if there any Cards after 10th" do
      journal = FactoryBot.build(:kingdom_journal)
      journal.params["card_list"][10] = "GameEngine::Renaissance::Ducat"
      expect(journal).to_not be_valid
    end

    it "should be invalid if there any non-randomiser card_shapeds after 10th" do
      journal = FactoryBot.build(:kingdom_journal)
      journal.params["card_list"][10] = "GameEngine::CardShapedThings::Artifacts::Key"
      expect(journal).to_not be_valid
    end
  end
end
