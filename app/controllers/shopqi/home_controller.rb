#encoding: utf-8
class Shopqi::HomeController < Shopqi::AppController # 官网首页
  layout 'shopqi'
  expose(:plan_types){KeyValues::Plan::Type.all.reverse}

  def agreement
    render layout: nil
  end

  def no_shop
    render template: 'shared/no_shop',layout: nil
  end

end
