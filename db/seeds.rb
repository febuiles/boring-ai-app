# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


Company.destroy_all

tickers = File.read("companies.json")
json = JSON.parse(tickers)

json.each do |_, c|
  Company.create!(ticker: c["ticker"].downcase, cik: c["cik_str"], name: c["title"])
end



#{"0":{"cik_str":320193,"ticker":"AAPL","title":"Apple Inc."},
