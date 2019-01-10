json.extract! journal, :id, :game_id, :user_id, :order, :type, :params, :created_at, :updated_at
json.url journal_url(journal, format: :json)
