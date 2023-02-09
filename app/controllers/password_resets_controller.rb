class PasswordResetsController < ApplicationController
  # フィルター
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      # ダイジェストの生成
      @user.create_reset_digest
      # メールの送信
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render "new"
    end
  end

  def edit
  end

  def update
    # passwordが空の場合
    if params[:user][:password].empty?
      # エラーを表示させる
      @user.errors.add(:password, :blank)
      render "edit"
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    # 無効なパスワードの場合
    else
      render "edit"
    end
  end

  private
    # strong parameters
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

  # フィルター
    # ユーザを取得する
    def get_user
      @user = User.find_by(email: params[:email])
    end

    # ユーザが正当であることを確認する
    def valid_user
      # ユーザが存在する、有効化されている、トークンが一致している
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうかを確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
