require "test_helper"

class SessionsHelperTest < ActionView::TestCase
  def setup
    @user = users(:michael)
    # 永続セッションをセット
    remember(@user)
  end

  # current_userメソッドに対するテスト
  ## 一時セッションが存在しない状態でウィンドウを開いた場合の認証・ログイン処理に対するテスト。
  ## current_userメソッドは、ブラウザを閉じたために一時セッションがない場合、ブラウザに保存されている永続セッションをもとに認証を行い、続けてログインと@current_userへの代入を行う。
  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    # @userのremember_digestを新しいトークンで上書きする
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
