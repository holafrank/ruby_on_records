class Backstore::ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]

  # GET /clients or /clients.json
  def index
    @clients = Client.all
  end

  # GET /clients/1 or /clients/1.json
  def show
    @client_sales = Sale.where(client: @client)
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients or /clients.json
  def create

    @client = Client.new(client_params)

    if @client.save
      redirect_to backstore_clients_path, notice: 'Cliente registrado exitosamente.'
    else
      render :new, status: :unprocessable_entity
      flash[:error] = "No se pudo registar al cliente: #{@client.errors.full_messages.join(', ')}"
      redirect_to backstore_new_client_path
    end

  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to backstore_client_path(@client), notice: "Client was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: backstore_client_path(@client) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy!

    respond_to do |format|
      format.html { redirect_to backstore_clients_path, notice: "Client was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:name, :contact)
    end
end
