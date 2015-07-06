module UsersHelper
  def ranking_class(rank, user)
    if user == @user
      return ""
    elsif rank.num_played == 0
      return "absent"
    else
      weeks = (Time.now - user.last_completed) / 2.weeks
      opacity = 100 - (weeks.to_i * 10)
      return "absent" if opacity < 10
      return "opacity#{opacity}"
    end
  end

  def rating_history(current, previous, opts = {})
    swap = opts[:swap] ? -1 : 1
    arrowDir = ["same", "up", "down"]
    str = "(&nbsp;"
    str << content_tag(:span, nil, class: "arrow #{arrowDir[(current <=> previous) * swap]}")
    str << "&nbsp;#{previous})"
    str.html_safe
  end
end
