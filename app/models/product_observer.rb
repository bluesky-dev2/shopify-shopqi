class ProductObserver < ActiveRecord::Observer

  def after_destroy(product)
    unless product.shop.products.exists?(vendor: product.vendor)
      product.shop.vendors.where(title: product.vendor).first.destroy
    end
    unless product.shop.products.exists?(product_type: product.product_type)
      product.shop.types.where(title: product.product_type).first.destroy
    end
  end

  def after_update(product)
    if product.vendor_changed?
      unless product.shop.products.exists?(vendor: product.vendor_was)
        product.shop.vendors.where(title: product.vendor_was).first.destroy
      end
    end
    if product.product_type_changed?
      unless product.shop.products.exists?(product_type: product.product_type_was)
        product.shop.types.where(title: product.product_type_was).first.destroy
      end
    end
  end

  def after_save(product)
    #保存新增的类型、厂商
    unless product.shop.types.exists?(title: product.product_type)
      product.shop.types.create title: product.product_type
    end

    unless product.shop.vendors.exists?(title: product.vendor)
      product.shop.vendors.create title: product.vendor
    end
  end

end
