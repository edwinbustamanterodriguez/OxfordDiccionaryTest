class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    @items = Item.all
  end

  # GET /items/1
  # GET /items/1.json
  def show
  end

  # GET /items/new
  def new
    @item = Item.new
    @result_search_api = ''
    @code_error = ''
    @message_error =''
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  def create
    @word = params[:word][:word]
    url = 'https://od-api.oxforddictionaries.com:443/api/v2/entries/en-gb/' + @word
    fields = 'definitions'
    app_id = '739a4e20'
    app_key = '0cccaf02f8d1d56e17bc7e64aaf2e4a8'

    @search = Faraday.get(url) do |req|
      req.params['fields'] = fields
      req.params['strictMatch'] = false
      req.headers['Content-Type'] = 'application/json'
      req.headers['app_id'] = app_id
      req.headers['app_key'] = app_key
    end

    if @search.success?
      @search_result = JSON.parse(@search.body,)
      @result_search_api = @search_result["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"][0]
      @item = Item.new(word: @word,definition:@result_search_api)
      @item.save
      if Item.count > 5
        Item.first.destroy
      end
      render :new
    else
      body_error_message = JSON.parse(@search.body,)
      @message_error =   "#{body_error_message["message"]} - #{body_error_message["error"] }"
      @code_error ="'ERROR:' #{@search.status} "
      render :new
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def item_params
      params.require(:item).permit(:word, :definition)
    end
end
