class RootController < ApplicationController
  def index
    @report = Report.new
  end
end
