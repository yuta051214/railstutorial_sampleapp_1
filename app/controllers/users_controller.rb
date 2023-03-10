class UsersController < ApplicationController
  # フィルター
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  # before_action：ログインしていること
  def index
    # ページネーション + 有効化されているユーザのみ表示する
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    # 有効化されているユーザのみ表示する
    redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  # before_action：ログインしている、かつ編集対象が自身であること
  def edit
    @user = User.find(params[:id])
  end

  # before_action：ログインしている、かつ更新対象が自身であること
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render "edit"
    end
  end

  # before_action：ログインしている、かつ管理者権限があること
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  # フォロー機能
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render "show_follow"
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render "show_follow"
  end


  private
    # Strong Parameters(adminを不正に変更できないようにする)
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # フィルター
    # 本人以外のユーザ情報へのアクセスを防ぐ
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # ログイン中のユーザが管理者かどうか確認する
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
