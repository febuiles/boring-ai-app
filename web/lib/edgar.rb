module Edgar
  def self.last_submission(cik)
    padded_cik = cik.rjust(10, "0")

    headers = { "User-Agent" => "mheroin Federico Builes v0.1, federico@mheroin.com" }
    url = "https://data.sec.gov/submissions/CIK#{padded_cik}.json"
    response = Faraday.get(url, nil, headers)

    # TODO clean up this mess
    json = JSON.parse(response.body)
    filings = json["filings"]["recent"]
    filings["form"].each.with_index do |filing, i|
      if filing == "10-K" || filing == "20-F"
        an = filings['accessionNumber'][i].try(:gsub, '-', '')
        pd = filings['primaryDocument'][i]
        next unless pd

        return "https://www.sec.gov/Archives/edgar/data/#{padded_cik}/#{an}/#{pd}"
      end
    end
  end
end
