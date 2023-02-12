class ApplicationController < ActionController::Base
  # session関連のヘルパーメソッドを全てのコントローラから利用できるようにする。
  include SessionsHelper

  private
    # フィルター
    # ログインしていない状態でのアクセスを防ぐ
    def logged_in_user
      unless logged_in?
        # アクセス先を session[:forwarding_url]に保存
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
