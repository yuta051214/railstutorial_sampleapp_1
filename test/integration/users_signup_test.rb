require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup infomation" do
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

  test "valid signup infomation" do
    # 登録フォームを表示
    get signup_path

    # assert_no_differenceメソッド内のブロックを実行する前後で、引数の'User.count'に差があることを確認する
    assert_difference 'User.count' do
      post users_path, params: { user: { name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password"}}
    end

    # リダイレクト先に移動する
    follow_redirect!
    # 登録失敗時にnewテンプレートが描画されることを確認する
    assert_template 'users/show'
    # サクセスメッセージが表示されることを確認する
    assert_not flash[:success].empty?
    # ログインしていることを確認する(test/test_helper.rbに書いたヘルパー)
    assert is_logged_in?
  end
end
