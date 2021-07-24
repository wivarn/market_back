# frozen_string_literal: true

class Account < ApplicationRecord
  # rodauth models
  has_many :account_active_session_keys
  has_many :account_authentication_audit_logs
  has_many :account_jwt_refresh_keys
  has_many :account_previous_password_hashes
  has_many :account_recovery_codes, foreign_key: :id
  # stores unlock key
  has_one :account_lockout, foreign_key: :id
  has_one :account_login_change_key, foreign_key: :id
  has_one :account_login_failure, foreign_key: :id
  has_one :account_otp_key, foreign_key: :id
  has_one :account_password_hash, foreign_key: :id
  has_one :account_password_reset_key, foreign_key: :id
  has_one :account_verification_key, foreign_key: :id

  has_many :listings
  has_many :carts
  has_many :purchases, class_name: 'Order', foreign_key: :account_id
  has_many :sales, class_name: 'Order', foreign_key: :seller_id
  has_one :listing_template
  has_one :stripe_connection
  has_one :address, as: :addressable

  validates :currency, inclusion: { in: %w[USD CAD] }, presence: true
end
