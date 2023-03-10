class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject

  # アカウント有効化機能
  def account_activation(user)
    @user = user

    mail to: user.email, subject: "Account activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject

  # パスワードリセット機能
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
