class MicropostsController < ApplicationController
  # フィルター
  # ログインしていない状態でのアクセスを防ぐ
  before_action :logged_in_user, only: [:create, :destroy]
  # 本人以外によるmicropostの削除を防ぐ
  before_action :correct_user, only: [:destroy]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    # micropostオブジェクトにアップロードされた画像をアタッチする
    @micropost.image.attach(params[:micropost][:image])

    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      # フィード機能
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # friendly forwarding機能に似た、HTTPの仕様。１つ前のURLを返す。
    redirect_to request.referrer || root_url
  end

  private
    # Strong Parameters
    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    # フィルター
    # 関連を用いてmicropostを取得する。取得できなかった場合は本人の投稿ではないという事なのでリダイレクトする。
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
