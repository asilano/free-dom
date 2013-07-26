require 'optparse'

text = nil
subj = nil

opts = OptionParser.new
opts.on("-s", "--subject SUBJECT", String)  {|val| subj = val}
opts.on("-f", "--file FILENAME", String) do |val|
  begin
    text = File.read(val)
  rescue
    puts "Failed to read body text from #{val}."
    exit 1
  end
end

rest = opts.parse(ARGV)

if text.nil? && !rest.blank?
  text = rest.join(' ')
end

if text.nil?
  puts "Please enter your message below."
  text = ""
  while (line = gets) !~ /^EOF/ do
    text << line
  end
end

User.find(:all, :conditions => ['contact_me = ?', true]).each do |u|
  UserMailer.announce(u, text, {:subject => subj}).deliver
end