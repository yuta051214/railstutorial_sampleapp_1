module SessionsHelper
  # --- ログイン時 ---
  # sessionメソッドで作成した一時Cookiesに(暗号化した？)ユーザーIDをセットする(この情報はブラウザを閉じると消えてしまう)。
  # cookiesメソッドを使うと永続セッションを作成できる(remember me 機能)。
  def log_in(user)
    session[:user_id] = user.id
    ## session[:user_id]で取り出せるようになる
  end

  # 永続セッションをセット
  def remember(user)
    # remember_token, remember_digestの生成と保存
    user.remember
    # ユーザIDを暗号化してから永続cookiesに代入する
    cookies.permanent.encrypted[:user_id] = user.id
    # 記憶トークンを永続cookiesに代入する
    cookies.permanent[:remember_token] = user.remember_token
    ## cookies.encrypted[:user_id], cookies[:remember_token]で取り出せるようになる
  end

  # --- ログイン中 ---
  # 現在ログイン中のユーザーを返す（いない場合はfalse、かも）
  ## 一時セッションがある場合、それをもとにユーザをDBから検索し、@current_userに代入する。
  ## ブラウザを閉じたために一時セッションがない場合、ブラウザに保存されている永続セッションをもとに認証を行い、続けてログインと@current_userへの代入を行う。
  def current_user
    if (user_id = session[:user_id])  # 「(user_id に session[:user_id]を代入した結果、)user_idが存在すれば」の意味
      @current_user ||= User.find_by(id: user_id)
    # sessions_controllerのcreateアクションとほぼ同様の処理
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # --- ログアウト時 ---
  # 永続的セッションを破棄する
  def forget(user)
    # DB上のremember_digestをnilで上書きする
    user.forget
    # cookiesを削除する
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在ログイン中のユーザーをログアウトする
  def log_out
    # 永続セッションを破棄する
    forget(current_user)
    # 一時セッションを破棄する
    session.delete(:user_id)
    # ＠current_userをnilにする
    @currrent_user = nil
  end
end
