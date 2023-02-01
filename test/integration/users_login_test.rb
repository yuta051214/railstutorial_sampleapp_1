require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # fixtures/users.yml の :michael を参照する
  def setup
    @user = users(:michael)
  end

  test "login with valid email & invalid password" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: { session: {email: @user.email, password: "invalid" } }
    assert_not is_logged_in?
    assert_template "sessions/new"
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid infomation followed by logout" do
    # ログイン
    get login_path
    post login_path, params: { session: { email: @user.email, password: "password" } }
    assert is_logged_in?
    assert_redirected_to @user # リダイレクト先が正しいか確認する
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    # ログアウト
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    delete logout_path  # 再度ログアウトすることで、複数タブから複数回ログアウトをクリックするユーザーをシュミレートする
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  # Remember_me機能をONでログインし、remember_tokenが存在することを確認する。
  test "login with remembering" do
    log_in_as(@user, remember_me: "1")
    assert_not_empty cookies[:remember_token]
  end

  # (まずRemember_me機能をONでログインしてremember_tokenをcookieに保存、その後)
  # Remember_me機能をOFFでログインし、remember_tokenが存在しないことを確認する。
  test "login without remembering" do
    log_in_as(@user, remember_me: "1")
    delete logout_path
    log_in_as(@user, remember_me: "0")
    assert_empty cookies[:remember_token]
  end
end
