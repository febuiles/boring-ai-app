module ModelsClient
  def self.generate(model:, source: )
    base_url = "https://fastapi-#{model}.fly.dev"
    conn = Faraday.new(url: base_url) do |f|
      f.request :json
      f.response :json
      f.options.timeout = 60
      f.options.open_timeout = 60
      f.adapter Faraday.default_adapter
    end

    response = conn.post('/generate') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = { source_doc: source }.to_json
    end

    response.body
  end
end
