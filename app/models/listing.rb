# frozen_string_literal: true

class Listing < ApplicationRecord
  SPORTS_CARDS = %w[HOCKEY BASEBALL BASKETBALL FOOTBALL SOCCER OTHER].freeze
  TRADING_CARDS = %w[CARDFIGHT_VANGUARD DRAGON_BALL_SUPER FLESH_AND_BLOOD MAGIC POKEMON STAR_WARS_DESTINY YUGIOH
                     OTHER].freeze
  COLLECTIBLES = %w[ANTIQUES ART COINS COMICS STAMPS TOYS WATCHES OTHER].freeze
  GRADING_COMPANIES = %w[BGS CSG HGA KSA MNT PSA SGC OTHER].freeze

  validates :account, :photos, :title, :condition, :category, :subcategory, :currency, :price, :domestic_shipping,
            :status, presence: true
  validates :title, length: { in: 2..256 }

  validates :category, inclusion: { in: %w[SPORTS_CARDS TRADING_CARDS COLLECTIBLES] }
  validates :subcategory, inclusion: { in: SPORTS_CARDS }, if: -> { category == 'SPORTS_CARDS' }
  validates :subcategory, inclusion: { in: TRADING_CARDS }, if: -> { category == 'TRADING_CARDS' }
  validates :subcategory, inclusion: { in: COLLECTIBLES }, if: -> { category == 'COLLECTIBLES' }

  validates :grading_company, inclusion: { in: GRADING_COMPANIES }, allow_nil: true
  validates :condition, inclusion: { in: (2..10).step(2).to_a }, if: -> { grading_company.nil? }
  validates :condition, inclusion: { in: (1..10).step(0.5).to_a }, if: -> { !grading_company.nil? }

  validates :status, inclusion: { in: %w[DRAFT ACTIVE REMOVED PENDING_SHIPMENT SHIPPED REFUNDED] }

  validates :price, :domestic_shipping, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ }, allow_blank: false
  validates :price, numericality: {
    greater_than_or_equal_to: 0.25,
    less_than: 100_000_000
  }
  validates :domestic_shipping, numericality: {
    greater_than_or_equal_to: 0,
    less_than: 100_000_000
  }
  validates :international_shipping,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 100_000_000
            }, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ },
            allow_nil: true, allow_blank: false
  validates :currency, inclusion: { in: %w[USD CAD] }

  belongs_to :account

  scope :draft, -> { where(status: 'DRAFT') }
  scope :active, -> { where(status: 'ACTIVE') }
  scope :removed, -> { where(status: 'REMOVED') }
  scope :pending_shipment, -> { where(status: 'PENDING_SHIPMENT') }
  scope :shipped, -> { where(status: 'SHIPPED') }
  scope :sold, -> { where(status: %w[PENDING_SHIPMENT SHIPPED]) }
  scope :refunded, -> { where(status: 'REFUNDED') }
end
