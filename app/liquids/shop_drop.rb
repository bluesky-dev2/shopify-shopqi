class ShopDrop < Liquid::Drop

  def initialize(shop, theme = nil)
    @shop = shop
    @theme = theme || shop.theme
  end

  def id
    @shop.id
  end

  def name
    @shop.name
  end

  def url
    @shop.primary_domain.url
  end

  # UrlFilter调用
  def asset_path(asset)
    @theme.asset_relative_path(asset)
  end

end
