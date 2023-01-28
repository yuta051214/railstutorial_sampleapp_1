module SessionsHelper
  # 渡されたユーザーでログインする
  # sessionメソッドで作成した一時CookiesにユーザーIDをセットする。cookiesメソッドだと永続セッションを作成できる。
  def log_in(user)
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 現在ログイン中のユーザーをログアウトする
  def log_out
    session.delete(:user_id)
    @currrent_user = nil
  end
end
