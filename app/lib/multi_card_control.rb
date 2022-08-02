class MultiCardControl < Control
  attr_reader :key, :preselect

  def initialize(opts = {})
    super
    @filter = filter_from(opts[:filter]) || ->(_card) { true }
    @preselect = filter_from(opts[:preselect]) || ->(_card) { false }
    if opts.key? :submit_text
      add_cardless_button({ text: opts[:submit_text],
                            value: "",
                            key: "submit" })
    end

    if opts.key? :null_choice
      add_cardless_button({ text:  opts[:null_choice][:text],
                            value: opts[:null_choice][:value],
                            key: "choice" })
    end
  end
end
