module Edgar
  def self.fetch_submissions(cik)
    padded_cik = cik.rjust(10, "0")

    headers = { "User-Agent" => "mheroin Federico Builes v0.1, federico@mheroin.com" }
    url = "https://data.sec.gov/submissions/CIK#{padded_cik}.json"
    response = Faraday.get(url, nil, headers)

    json = JSON.parse(response.body)
    filings = json["filings"]["recent"]
    filings["form"].each.with_index do |filing, i|
      if filing == "10-K" || filing == "20-F"
        an = filings['accessionNumber'][i].try(:gsub, '-', '')
        pd = filings['primaryDocument'][i]
        next unless pd

        rep_url = "https://www.sec.gov/Archives/edgar/data/#{padded_cik}/#{an}/#{pd}"
        connection = Faraday.new do |conn|
          conn.use Faraday::FollowRedirects::Middleware
          conn.adapter Faraday.default_adapter
        end
        rep_res = connection.get(rep_url, nil, headers)
        if rep_res.success?
          File.open('rep.html', 'w') do |f|
            f.write(rep_res.body)
          end
        else
          raise "Could not process url: #{rep_url}"
        end
      end
    end
  end
end
