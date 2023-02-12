class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # ログイン中の場合、投稿フォームを表示する必要がある
      @micropost = current_user.microposts.build
      # フィード
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
