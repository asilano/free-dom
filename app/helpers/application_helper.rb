module ApplicationHelper
  def header_class
    cls = 'small-20vh'
    cls << ' medium-40vh' if current_page?(root_path)
    cls
  end

  def display_event_for_user(event)
    event.gsub(/\{(?<user_id>\d+)\?(?<private>[^|]*)\|(?<public>[^}]*)\}/) do |str|
      match = Regexp.last_match
      if current_user && match[:user_id] == current_user.id.to_s
        match[:private]
      else
        match[:public]
      end
    end
  end

  def display_event_for_public(event)
    event.gsub(/\{(?<user_id>\d+)\?(?<private>[^|]*)\|(?<public>[^}]*)\}/,
               '\k<public>')
  end
end
