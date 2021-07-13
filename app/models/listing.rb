# frozen_string_literal: true

class Listing < ApplicationRecord
  CATEGORIES = %w[SPORTS_CARDS TRADING_CARDS COLLECTIBLES].freeze
  SPORTS_CARDS = %w[HOCKEY BASEBALL BASKETBALL FOOTBALL SOCCER OTHER].freeze
  TRADING_CARDS = %w[CARDFIGHT_VANGUARD DRAGON_BALL_SUPER FLESH_AND_BLOOD MAGIC POKEMON STAR_WARS_DESTINY YUGIOH
                     OTHER].freeze
  COLLECTIBLES = %w[ANTIQUES ART COINS COMICS STAMPS TOYS WATCHES OTHER].freeze
  GRADING_COMPANIES = %w[BGS CSG HGA KSA MNT PSA SGC OTHER].freeze

  validates :account, :title, :currency, :shipping_country, :status, presence: true
  validates :status, inclusion: { in: %w[DRAFT ACTIVE REMOVED RESERVED PENDING_SHIPMENT SHIPPED REFUNDED] }
  validates :title, length: { in: 2..256 }
  validates :currency, inclusion: { in: %w[USD CAD] }
  validates :shipping_country, inclusion: { in: %w[USA CAN] }
  validates :grading_company, inclusion: { in: GRADING_COMPANIES }, allow_nil: true, allow_blank: true
  validates :international_shipping,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 100_000_000
            }, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ },
            allow_nil: true, allow_blank: false

  with_options if: -> { status != 'DRAFT' } do |active|
    active.validates :account, :photos, :condition, :category, :subcategory, :price, :domestic_shipping,
                     presence: true

    active.validates :category, inclusion: { in: CATEGORIES }
    active.validates :subcategory, inclusion: { in: SPORTS_CARDS }, if: -> { category == 'SPORTS_CARDS' }
    active.validates :subcategory, inclusion: { in: TRADING_CARDS }, if: -> { category == 'TRADING_CARDS' }
    active.validates :subcategory, inclusion: { in: COLLECTIBLES }, if: -> { category == 'COLLECTIBLES' }

    active.validates :condition, inclusion: { in: (2..10).step(2).to_a },
                                 if: -> { status != 'DRAFT' && !grading_company.present? }
    active.validates :condition, inclusion: { in: (1..10).step(0.5).to_a },
                                 if: -> { status != 'DRAFT' && grading_company.present? }

    active.validates :price, :domestic_shipping, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ },
                                                 allow_blank: false
    active.validates :price, numericality: {
      greater_than_or_equal_to: 1,
      less_than: 100_000_000
    }
    active.validates :domestic_shipping, numericality: {
      greater_than_or_equal_to: 0,
      less_than: 100_000_000
    }
  end

  with_options if: -> { status == 'DRAFT' } do |draft|
    draft.validates :category, inclusion: { in: CATEGORIES }, allow_blank: true
    draft.validates :subcategory, inclusion: { in: SPORTS_CARDS }, if: -> { category == 'SPORTS_CARDS' },
                                  allow_blank: true
    draft.validates :subcategory, inclusion: { in: TRADING_CARDS }, if: -> { category == 'TRADING_CARDS' },
                                  allow_blank: true
    draft.validates :subcategory, inclusion: { in: COLLECTIBLES }, if: -> { category == 'COLLECTIBLES' },
                                  allow_blank: true

    draft.validates :condition, inclusion: { in: (2..10).step(2).to_a }, allow_blank: true, allow_nil: true,
                                if: -> { status == 'DRAFT' && !grading_company.present? }

    draft.validates :condition, inclusion: { in: (1..10).step(0.5).to_a }, allow_blank: true, allow_nil: true,
                                if: -> { status == 'DRAFT' && grading_company.present? }

    draft.validates :price, :domestic_shipping, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ },
                                                allow_blank: true, allow_nil: true
    draft.validates :price, numericality: {
      greater_than_or_equal_to: 0,
      less_than: 100_000_000
    }, allow_blank: true, allow_nil: true
    draft.validates :domestic_shipping, numericality: {
      greater_than_or_equal_to: 0,
      less_than: 100_000_000
    }, allow_blank: true, allow_nil: true
  end

  belongs_to :account

  scope :draft, -> { where(status: 'DRAFT') }
  scope :active, -> { where(status: 'ACTIVE') }
  scope :removed, -> { where(status: 'REMOVED') }
  scope :pending_shipment, -> { where(status: 'PENDING_SHIPMENT') }
  scope :shipped, -> { where(status: 'SHIPPED') }
  scope :sold, -> { where(status: %w[PENDING_SHIPMENT SHIPPED]) }
  scope :refunded, -> { where(status: 'REFUNDED') }

  def active?
    status == 'ACTIVE'
  end
end
