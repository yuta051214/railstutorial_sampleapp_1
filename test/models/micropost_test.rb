require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  # 正当なデータをバリデーションが通すこと
  test "should be valid" do
    assert @micropost.valid?
  end

  # 不正なデータをバリデーションが通さないこと
    # user_id が不正
    test "user id should be present" do
      @micropost.user_id = nil
      assert_not @micropost.valid?
    end

    # content が不正
    test "content should be present" do
      @micropost.content = "   "
      assert_not @micropost.valid?
    end

    # content が140文字を超過
    test "content should be at most 140 characters" do
      @micropost.content = "a" * 141
      assert_not @micropost.valid?
    end


    # 表示順序(新しい順)
    test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
