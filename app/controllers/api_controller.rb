class ApiController < ActionController::Base
  respond_to :json

  before_filter :default_format_json

  private
  def default_format_json
    request.format = "json" unless params[:format]
  end
end