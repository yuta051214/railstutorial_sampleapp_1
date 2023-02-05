class SessionsController < ApplicationController
  def new
  end

  # ログイン(=セッションを確立すること)
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      # 一時セッションをセット
      log_in user
      # 永続セッションをセット(チェックボックスによって場合分け)
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      # フレンドリ・フォワーディング機能
      redirect_back_or user
    else
      flash.now[:danger] = "Invalid email/password combination"
      render 'new'
    end
  end

  # ログアウト(=セッションを破棄すること)
  def destroy
    log_out if logged_in?  # エラー対策：複数タブからの複数回ログアウト対策(ユーザがログイン中の場合のみ実行する)
    redirect_to root_url
  end
end
