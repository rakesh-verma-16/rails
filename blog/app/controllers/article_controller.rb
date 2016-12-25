class ArticleController < ApplicationController

  before_action :validate_params, only: [:create]

  def create
    create_params = created_params
    @article = Article.new(create_params)
    respond_to do |format|
      if @article.save
        format.html { redirect_to (article_path(@article)), notice: 'Article was successfully created.' }
        format.json { render action: 'show', status: :created, location: @article }
      end
    end

  end

  def show
    @article = Article.where(id: params[:id])
  end

  def new
    @article = Article.new
  end

  def index
    @articles = Article.all.order("created_at DESC")
  end

  private

  def created_params
    permitted_params = params.require(:article).permit(:title, :content, :author)
  end

  def validate_params
    if params[:article][:title].blank? || params[:article][:content].blank? || params[:article][:author].blank?
      render json: { message: "params invalid", status: :unprocessable_entity }
    end
  end

end
