require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    # 配列deliversを初期化
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    # 登録フォームを表示
    get signup_path

    # assert_no_differenceメソッド内のブロックを実行する前後で、引数の'User.count'に差がないことを確認する
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "", email: "user@invalid", password: "foo", password_confirmation: "bar"}}
    end

    # 登録失敗時にnewテンプレートが再描画されることを確認する
    assert_template 'users/new'
    # エラーメッセージが表示されることを確認する
    assert_select 'div#error_explanation'
  end

  test "valid signup information with account activation" do
    # 登録フォームを表示
    get signup_path

    # assert_no_differenceメソッド内のブロックを実行する前後で、引数の'User.count'に差があることを確認する
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password"}}
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?

    # リダイレクト先に移動する
    follow_redirect!
    # # 登録失敗時にnewテンプレートが描画されることを確認する
    assert_template 'users/show'
    # # ログインしていることを確認する(test/test_helper.rbに書いたヘルパー)
    assert is_logged_in?
  end
end
