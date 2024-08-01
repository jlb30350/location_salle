# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
    def account_deleted_email(email)
      @email = email
      mail(to: @email, subject: 'Votre compte a été supprimé')
    end
  end