class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # Ajax(条件文に似た処理)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    # 関連 relationship.followed で、フォローしているユーザを返す
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    # Ajax
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
