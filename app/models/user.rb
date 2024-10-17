class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable,
         :trackable, :omniauthable, omniauth_providers: %i[auth0]

  validates :nickname, presence: true, length: { maximum: 50 }

  has_many :posts, dependent: :destroy

  def nickname_initial
    nickname.first.upcase
  end

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.password = Devise.friendly_token[0, 20]
      user.nickname = auth.info.nickname
    end
  end

  private

  # NOTE: IPアドレスを持ちたくなかったため、以下のメソッドをオーバーライド
  def update_tracked_fields(request)
    old_current, new_current = self.current_sign_in_at, Time.now
    self.last_sign_in_at     = old_current || new_current
    self.current_sign_in_at  = new_current
    self.sign_in_count ||= 0
    self.sign_in_count += 1
  end

  def email_required?
    (provider.blank? || !email.blank?) && super
  end
end
