module ModelsClient
  BASE_URL = 'https://fastapi-llama.fly.dev'

  def self.generate(source_doc)
    conn = Faraday.new(url: BASE_URL) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    response = conn.post('/generate') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = { source_doc: source_doc }.to_json
    end

    response.body
  end
end
