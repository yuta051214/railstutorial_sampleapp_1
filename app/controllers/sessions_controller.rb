class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      # 一時セッションをセット
      log_in user
      # 永続セッションをセット(チェックボックスによって場合分け)
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = "Invalid email/password combination"
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?  # エラー対策：複数タブからの複数回ログアウト対策(ユーザがログイン中の場合のみ実行する)
    redirect_to root_url
  end
end
