# frozen_string_literal: true

require 'roda'
require 'sequel'
require 'bcrypt'

class Auth < Roda
  plugin :middleware

  plugin :rodauth, json: :only do
    enable :login, :logout, :jwt

    account_password_hash_column :password_hash

    jwt_secret '1'
  end

  route do |r|
    env['rodauth'] = rodauth
    r.rodauth
  end
end
