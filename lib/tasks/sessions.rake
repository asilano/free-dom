task :drop_old_sessions => :environment do
  sql = "DELETE FROM sessions WHERE (updated_at < '#{2.weeks.ago}')"
  ActiveRecord::Base.connection.execute(sql)
end