module CardDecorators
  module BasicDecorators
    # Define the text of a card
    def text(*lines)
      define_singleton_method(:raw_text) do
        lines.reject { _1 == :hr }
             .join(" ")
      end

      str = lines
        .slice_when { |l| l == :hr }
        .map { |sub| sub.reject { |l| l == :hr }.join("\n") }
        .join("<hr>")
      define_method(:text) { self.class.card_text }
      define_singleton_method(:cost_str) { " (cost: #{raw_cost})" if raw_cost }
      define_singleton_method(:card_text) do
        "<span class='metadata'>#{types.map(&:to_s).map(&:humanize).join("-")}#{cost_str}</span>\n#{str}"
      end
    end

    # Define the raw cost of a card, before any modifications like Bridge
    def costs(cost)
      raise unless cost.is_a? Integer

      define_singleton_method(:raw_cost) { cost }
    end

    def sort_key
      [raw_cost, readable_name]
    end
  end
end
