class User < ApplicationRecord
  # パスワード認証(authentication)
  has_secure_password

  # 仮想の属性
  # remember_token：Remember_me機能のための、DBへは保存せずにブラウザにのみ保存する仮想の属性(DBへ保存するのはハッシュ化後のremember_digest属性)
  # activation_token：アカウント有効化のために、メールで送信する認証用のトークン
  # reset_token：パスワードの再設定用のトークン
  attr_accessor :remember_token, :activation_token, :reset_token

  # コールバック
  # emailの小文字化
  before_save :downcase_email
  # アカウントの有効化
  before_create :create_activation_digest

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
    # 渡された記憶トークンが、DBに保存されている(記憶)ダイジェストと一致したらtrueを返す
    def authenticated?(attribute, token)
      # attributeの値によってremember_digestとactivation_digestを切り替える
      digest = self.send("#{attribute}_digest")
      # エラー対策：(remember_)digestが存在しない場合にfalseを返す処理を追加
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end

    # --- ログアウト時 ---
    # ユーザーのログイン情報を破棄する
    def forget
      update_attribute(:remember_digest, nil)
    end


  # アカウント有効化機能
    # アカウントを有効にする
    def activate
      self.update_columns(activated: true, activated_at: Time.zone.now)
    end

    # アカウント有効化のためのメールを送信する
    def send_activation_email
      UserMailer.account_activation(self).deliver_now
    end

  # パスワードリセット機能
    # トークンの生成、ダイジェストの保存
    def create_reset_digest
      self.reset_token = User.new_token
      update_attribute(:reset_digest, User.digest(self.reset_token))
      update_attribute(:reset_sent_at, Time.zone.now)
    end

    # メールを送信する
    def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
    end

    # パスワード再設定の期限が切れている場合はtrueを返す
    def password_reset_expired?
      reset_sent_at < 2.hours.ago
    end

  private
  # コールバック
    # emailの小文字化
    def downcase_email
      self.email = self.email.downcase  ## 省略形： { self.email = email.downcase }
    end

    # アカウントの有効化（Account Activation）
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
