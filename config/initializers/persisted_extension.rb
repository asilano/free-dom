module PersistedExtension
  def persisted
    select(&:persisted?)
  end
end