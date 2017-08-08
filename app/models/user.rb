class User < ApplicationRecord
  has_many :meds
  has_many :shares

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         #line added to make user omniauthAble
         :omniauthable, omniauth_providers: [:facebook]

  validates :name, presence: true, allow_nil: false, allow_blank: false
  validates :email, presence: true, allow_nil: false, allow_blank: false
  # validates :zipcode, presence: true, allow_nil: false, allow_blank: false
  # validates :address, presence: true, allow_nil: false, allow_blank: false

  def self.find_for_facebook_oauth(auth)
    user_params = auth.slice(:provider, :uid)
    user_params[:email] = auth.info.email
    user_params[:name] = "#{auth.info.first_name} #{auth.info.last_name}"
    user_params[:facebook_picture_url] = auth.info.image
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    user_params = user_params.to_h

    user = User.find_by(provider: auth.provider, uid: auth.uid)
    user ||= User.find_by(email: auth.info.email) # User did a regular sign up in the past.
    if user
      user.update(user_params)
    else
      user = User.new(user_params)
      user.password = Devise.friendly_token[0,20]  # Fake password for validation
      user.save
    end

    return user
  end
end
