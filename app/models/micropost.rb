class Micropost < ApplicationRecord
  # リレーション
  belongs_to :user

  # Active Storage(モデルとファイルの間に一対一のマッピングを設定)
  has_one_attached :image

  # default_scope：DBから要素を取得した際、デフォルトの順序を指定するメソッド
  # ->：ラムダ式。Procやlambda(無名関数)を作成する文法。ブロックを引数に取り、callメソッドが呼ばれたときにブロック内の処理を評価する。
  default_scope -> { order(created_at: :desc) }

  # バリデーション
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png], message: "must be a valid image format" },
                    size: { less_than: 5.megabytes, message: "should be less than 5MB" }

  # 表示用のリサイズ済み画像を返す
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end
end
