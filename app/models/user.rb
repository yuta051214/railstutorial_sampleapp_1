class User < ApplicationRecord
  # Remember_me機能のための、DBへは保存せずにブラウザにのみ保存する仮想の属性(DBへ保存するのはハッシュ化後のremember_digest属性)
  attr_accessor :remember_token

  # パスワード認証(authentication)
  has_secure_password

  # コールバック
  before_save { self.email = self.email.downcase}
  ## 省略形： { self.email = email.downcase }

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  # allow_nil: trueは、update時にPWの変更がない場合にバリデーションにかからないように追加
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列、つまりPWのハッシュ値を返す(fixtureと、rememberメソッドで利用する)
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end


  # Remember me 機能(永続cookie(permanent cookies))
  # この機能を使うことでユーザーが明示的にログアウトを実行しない限り、例えブラウザを閉じた後でも、ログイン状態を維持することができる。
  # (ブラウザを閉じてまた開くと、そのタイミングで自動的に永続cookieを用いてログイン処理が実行される、っぽい)
  # ブラウザにはremember_tokenと暗号化されたuser_idを、DBにはremember_digestを保存する。
    # --- ログイン時 ---
    # ランダムなトークンを発行する
    def self.new_token
      SecureRandom.urlsafe_base64
    end

    # 永続セッションのために記憶トークンを生成しユーザと関連付ける。さらにそれをハッシュ化した記憶ダイジェストをDBに保存する。
    def remember
      # 記憶トークンを生成し、仮想の属性remember_tokenに代入する。これによりユーザとトークンを関連づける。
      self.remember_token = User.new_token
      # 仮想の属性remember_tokenをハッシュ化し、remember_digest属性を更新する。
      update_attribute(:remember_digest, User.digest(self.remember_token))  # update_attributeはバリデーションを素通りできる
    end

    # --- ログイン中 ---
    # 渡された記憶トークンが、DBに保存されている記憶ダイジェストと一致したらtrueを返す
    def authenticated?(remember_token)
      # エラー対策：remember_digestが存在しない場合にfalseを返す処理を追加
      return false if remember_digest.nil?
      BCrypt::Password.new(self.remember_digest).is_password?(remember_token)  # self.remember_digestはremember_digestと省略可能
    end

    # --- ログアウト時 ---
    # ユーザーのログイン情報を破棄する
    def forget
      update_attribute(:remember_digest, nil)
    end
end
