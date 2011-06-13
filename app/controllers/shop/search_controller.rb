#encoding: utf-8
class Shop::SearchController < Shop::AppController

  expose(:shop) { Shop.at(request.subdomain) }

  expose(:results) do
    if params[:q].blank?
      []
    else
      ThinkingSphinx.search params[:q], classes: [Product, Blog, Page]
    end
  end

  def show
    assign = template_assign('search' => SearchDrop.new(results, params[:q]))
    html = Liquid::Template.parse(File.read(shop.theme.layout_theme_path)).render(shop_assign('search', assign))
    render text: html
  end
end
