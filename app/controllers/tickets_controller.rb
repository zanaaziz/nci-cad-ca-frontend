class TicketsController < ApplicationController
  def index
    response = Faraday.get("#{ENV['API_BASE_URL']}/tickets") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end

    @tickets = JSON.parse(response.body)
  end

  def show
    ticket_response = Faraday.get("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end

    messages_response = Faraday.get("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}/messages") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end

    @ticket = JSON.parse(ticket_response.body)
    @messages = JSON.parse(messages_response.body)
  end

  def create_message
    response = Faraday.post("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}/messages", { content: params[:content] }.to_json, "Content-Type" => "application/json") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end
  
    if response.status == 201
      @message = JSON.parse(response.body)
    else
      @message = nil
    end
  
    respond_to do |format|
      if @message
        format.turbo_stream
        format.html { redirect_to ticket_path(params[:id]), notice: "Message sent!" }
      else
        flash[:alert] = "Failed to send message."
        format.html { redirect_to ticket_path(params[:id]) }
      end
    end
  end
end