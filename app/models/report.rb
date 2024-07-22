class Report < ApplicationRecord
  has_one_attached :file

  def self.create_from_file(cik, body)
    company = Company.find_by(cik: cik)
    # TODO fix year, field duplication
    report = Report.create!(cik: cik, year: 2023, ticker: company.ticker, name: company.name)
    report.file.attach(io: StringIO.new(body), filename: "#{cik}.htm")
  end
end
