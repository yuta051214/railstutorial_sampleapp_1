class ApplicationController < ActionController::Base
  # log_in, log_out, current_user などのsession関連のヘルパーメソッドを、全てのコントローラから利用できるようにする。
  include SessionsHelper
end
