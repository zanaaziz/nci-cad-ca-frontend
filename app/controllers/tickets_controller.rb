# Controller for managing tickets and their associated actions
class TicketsController < ApplicationController
  # Fetches all tickets for the user
  def index
    response = Faraday.get("#{ENV['API_BASE_URL']}/tickets") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}" # Authenticate request with user token
    end

    # Parse the response if successful, otherwise return an empty array
    if response.status == 200
      @tickets = JSON.parse(response.body)
    else
      @tickets = []
    end
  end
  
  # Fetches details of a specific ticket along with its messages
  def show
    # Fetch the ticket details
    ticket_response = Faraday.get("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end

    # Fetch associated messages for the ticket
    messages_response = Faraday.get("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}/messages") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end

    # Parse responses into instance variables
    @ticket = JSON.parse(ticket_response.body)
    @messages = JSON.parse(messages_response.body)
  end

  # Fetch ticket details for editing
  def edit
    show # Reuse the show logic to fetch ticket details
  end
  
  # Updates the name of a ticket
  def update
    response = Faraday.put("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}", { name: params[:name] }.to_json, "Content-Type" => "application/json") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end
  
    if response.status == 200
      redirect_to ticket_path(params[:id]), notice: "Ticket updated successfully!" # Redirect on success
    else
      flash[:alert] = "Failed to update ticket." # Show error message on failure
      render :edit
    end
  end

  # Displays the form for creating a new ticket
  def new
    @ticket = {} # Initialize an empty ticket object for the form
  end

  # Creates a new ticket and its first message
  def create_ticket
    # Send API request to create the ticket
    ticket_response = Faraday.post("#{ENV['API_BASE_URL']}/tickets", { name: params[:name], description: params[:description] }.to_json, "Content-Type" => "application/json") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end
  
    if ticket_response.status == 201
      ticket = JSON.parse(ticket_response.body)

      # Automatically create the first message using the ticket's description
      Faraday.post("#{ENV['API_BASE_URL']}/tickets/#{ticket['id']}/messages", { content: ticket['description'] }.to_json, "Content-Type" => "application/json") do |req|
        req.headers["Authorization"] = "Bearer #{current_user_token}"
      end
  
      redirect_to ticket_path(ticket['id']), notice: "Ticket created with the first message!"
    else
      Rails.logger.error "Failed to create ticket: #{ticket_response.body}" # Log error for debugging
      flash[:alert] = "Failed to create ticket."
      render :new
    end
  end

  # Adds a message to a ticket
  def create_message
    # Send API request to add a new message
    response = Faraday.post("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}/messages", { content: params[:content] }.to_json, "Content-Type" => "application/json") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end
  
    if response.status == 201
      @message = JSON.parse(response.body) # Parse the created message
    else
      @message = nil
    end
  
    # Respond appropriately based on the format
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

  # Deletes a ticket
  def destroy
    response = Faraday.delete("#{ENV['API_BASE_URL']}/tickets/#{params[:id]}") do |req|
      req.headers["Authorization"] = "Bearer #{current_user_token}"
    end
  
    if response.status == 200
      redirect_to "/", notice: "Ticket deleted successfully!" # Redirect to the home page on success
    else
      flash[:alert] = "Failed to delete ticket." # Show error message on failure
      redirect_to "/"
    end
  end
end