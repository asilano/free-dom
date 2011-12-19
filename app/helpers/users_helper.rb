module UsersHelper
  def ranking_class(rank, user)
    if user == @user
      return ""
    elsif rank.num_played == 0
      return "absent"
    else
      logger.info("Comparing #{Time.now} to #{user.last_completed}")
      weeks = (Time.now - user.last_completed) / 2.weeks
      logger.info("= #{weeks} weeks")
      opacity = 100 - (weeks.to_i * 10)
      return "absent" if opacity < 10
      return "opacity#{opacity}"
    end
  end
end
