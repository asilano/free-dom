module ApplicationHelper
  def header_class
    cls = 'small-20vh'
    cls << ' medium-40vh' if current_page?(root_path)
    cls
  end
end
