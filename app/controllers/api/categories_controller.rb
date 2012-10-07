class Api::CategoriesController < ApiController

  respond_to :json

  # GET /categories.json
  def index
    @categories = Category.all
    respond_with @categories
  end

  # GET /categories/1
  def show
    @category = Category.find(params[:id])
    respond_with @category
  end

  # POST /categories.json
  def create
    @category = Category.new(category_params)
    respond_wth @category.save
  end

  # PATCH/PUT /categories/1.json
  def update
    @category = Category.find(params[:id])
    respond_with @category.update_attributes(category_params)
  end

  # DELETE /categories/1.json
  def destroy
    @category = Category.find(params[:id])
    respond_with @category.destroy
  end

  private

    # Use this method to whitelist the permissible parameters. Example:     
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of 
    # permissible attributes.
    def category_params
      params.require(:category).permit(:title)
    end
end
