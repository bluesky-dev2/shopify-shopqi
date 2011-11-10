#encoding: utf-8
#订单关联的liquid属性
class CustomerDrop < Liquid::Drop

  def initialize(customer)
    @customer = customer
  end

  delegate :email, :name, to: :@customer

  def default_address
    address =  @customer.addresses.where(default_address: true).first ||  @customer.addresses.first
    CustomerAddressDrop.new address
  end

  def addresses_count
    @customer.addresses.size
  end

  def orders
    @customer.orders.map do |order|
      OrderDrop.new  order
    end
  end

end

class CustomerAddressDrop < Liquid::Drop

  def initialize(address)
    @address = address
  end

  delegate :zip, :phone, :address1, :address2, to: :@address

  def country
    @address.country_name
  end

  def province_code
    @address.province_name
  end

  def city
    @address.city_name
  end

end
