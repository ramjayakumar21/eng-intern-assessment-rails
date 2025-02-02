class ArticlesController < ApplicationController

  # GET /articles
  # if search param is present, search for articles with that param
  # else, return all articles
  def index
    @articles = Rails.cache.fetch('articles', expires_in: 10.minutes) do
      if params[:search].present?
        Article.search(params[:search])
      else
        Article.all
      end
    end
  end
  

  # GET /articles/:id
  # find article with id and render it
  def show
    @article = Rails.cache.fetch(["article", params[:id]], expires_in: 10.minutes) do
      Article.find(params[:id])
    end
  end

  # GET /articles/:id/edit
  # find article with id and render edit page
  def edit
    @article = Article.find(params[:id])
  end

  # PUT /articles/:id
  # find article with id, update it with params, and redirect to it
  def update
    @article = Article.find(params[:id])

    clear_cache(@article)

    if (@article.update(article_params))
      redirect_to @article
    else
      render 'edit'
    end
  end

  # GET /articles/new
  # render new article page
  def new
    @article = Article.new
  end

  # POST /articles
  # create new article from params, save it, and redirect to it
  def create
    @article = Article.new(article_params)

    if (@article.save)
      Rails.cache.delete('articles')
      redirect_to @article
    else
      render 'new'
    end
  end

  # DELETE /articles/:id
  # find article with id and delete it
  def destroy
    @article = Article.find(params[:id])

    clear_cache(@article)

    @article.destroy
    redirect_to articles_path
  end

  # Private method to only allow certain parameters
  private def article_params
    params.require(:article).permit(:title, :author, :content, :date )
  end

  # Private method to clear cache
  private def clear_cache(article)
    Rails.cache.delete(['article', article.id])
    Rails.cache.delete('articles')
  end

end
