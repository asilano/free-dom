require 'rails_helper'

RSpec.describe "games/index", type: :view do
  before(:each) do
    assign(:games, [
      Game.create!(
        :name => "Name"
      ),
      Game.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of games" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
