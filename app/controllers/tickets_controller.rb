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

  def edit
    show
  end
  
  def update
    response = Faraday.put("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}", { name: params[:name] }.to_json, "Content-Type" => "application/json") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end
  
    if response.status == 200
      redirect_to ticket_path(params[:id]), notice: "Ticket updated successfully!"
    else
      flash[:alert] = "Failed to update ticket."
      render :edit
    end
  end

  def new
    @ticket = {}
  end

  def create_ticket
    ticket_response = Faraday.post("#{ENV['API_BASE_URL']}/tickets", { name: params[:name], description: params[:description] }.to_json, "Content-Type" => "application/json") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end
  
    if ticket_response.status == 201
      ticket = JSON.parse(ticket_response.body)
  
      Faraday.post("#{ENV['API_BASE_URL']}/tickets/#{ticket['id']}/messages", { content: ticket['description'] }.to_json, "Content-Type" => "application/json") do |req|
        req.headers["Authorization"] = "Bearer #{current_user_token}"
      end
  
      redirect_to ticket_path(ticket['id']), notice: "Ticket created with the first message!"
    else
      Rails.logger.error "Failed to create ticket: #{ticket_response.body}"
      flash[:alert] = "Failed to create ticket."
      render :new
    end
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

  def destroy
    response = Faraday.delete("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end
  
    if response.status == 200
      redirect_to "/", notice: "Ticket deleted successfully!"
    else
      flash[:alert] = "Failed to delete ticket."
      redirect_to "/"
    end
  end
end