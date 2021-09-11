# frozen_string_literal: true

class Account < ApplicationRecord
  ROLES = %w[admin partner promo seller user].freeze
  SELLERS = %w[admin partner promo seller].freeze
  INTERNAL = %w[admin partner].freeze

  FEE = {
    'admin' => 0,
    'partner' => 0,
    'promo' => 2,
    'seller' => 5,
    'user' => 5
  }

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
  has_many :carts, class_name: 'Cart', foreign_key: :buyer_id
  has_many :purchases, class_name: 'Order', foreign_key: :buyer_id
  has_many :sales, class_name: 'Order', foreign_key: :seller_id
  has_many :sent_messages, class_name: 'Message', foreign_key: :sender_id
  has_many :recieved_messages, class_name: 'Message', foreign_key: :recipient_id
  has_one :listing_template
  has_one :payment
  has_one :address, as: :addressable

  validates :role, inclusion: { in: ROLES }, presence: true

  mount_uploader :picture, ImageUploader

  def admin?
    role == 'admin'
  end

  def seller?
    SELLERS.include?(role)
  end

  def fee
    FEE[role] || 5
  end

  def full_name
    "#{given_name} #{family_name}"
  end

  private

  def internal?
    INTERNAL.include?(role)
  end
end
