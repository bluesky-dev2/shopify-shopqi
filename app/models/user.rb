# encoding: utf-8
class User < ActiveRecord::Base
  include SentientUser
  after_initialize :init_shop
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,:name

  belongs_to :shop
  accepts_nested_attributes_for :shop

  def init_shop
    if new_record? 
      build_shop
    end
  end
  

end
