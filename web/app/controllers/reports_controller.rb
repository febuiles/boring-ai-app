class ReportsController < ApplicationController
  def show
    ticker = params[:ticker]
    Rails.logger.info("Aqui")
    return head :not_found unless ticker.present?

    @company = Company.find_by(ticker: ticker)
  end

  def create
    ticker = report_params[:ticker].downcase
    @company = Company.find_by(ticker: ticker)
    return head :not_found unless @company

    redirect_to reports_path(ticker: ticker)
  end

  def report_params
    params.require(:report).permit(:ticker)
  end
end
