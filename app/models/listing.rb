# frozen_string_literal: true

class Listing < ApplicationRecord
  include AASM

  CATEGORIES = %w[SPORTS_CARDS TRADING_CARDS COLLECTIBLES].freeze
  SPORTS_CARDS = %w[HOCKEY BASEBALL BASKETBALL FOOTBALL SOCCER OTHER].freeze
  TRADING_CARDS = %w[CARDFIGHT_VANGUARD DRAGON_BALL_SUPER FLESH_AND_BLOOD MAGIC POKEMON STAR_WARS_DESTINY YUGIOH
                     OTHER].freeze
  COLLECTIBLES = %w[ANTIQUES ART COINS COMICS STAMPS TOYS WATCHES OTHER].freeze
  GRADING_COMPANIES = %w[BGS CSG HGA KSA MNT PSA SGC OTHER].freeze

  validates :account, :title, :currency, :shipping_country, presence: true
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

  with_options if: -> { aasm_state != :draft } do |active|
    active.validates :account, :photos, :condition, :category, :subcategory, :price, :domestic_shipping,
                     presence: true

    active.validates :category, inclusion: { in: CATEGORIES }
    active.validates :subcategory, inclusion: { in: SPORTS_CARDS }, if: -> { category == 'SPORTS_CARDS' }
    active.validates :subcategory, inclusion: { in: TRADING_CARDS }, if: -> { category == 'TRADING_CARDS' }
    active.validates :subcategory, inclusion: { in: COLLECTIBLES }, if: -> { category == 'COLLECTIBLES' }

    active.validates :condition, inclusion: { in: (2..10).step(2).to_a },
                                 if: -> { aasm_state != :draft && !grading_company.present? }
    active.validates :condition, inclusion: { in: (1..10).step(0.5).to_a },
                                 if: -> { aasm_state != :draft && grading_company.present? }

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

  with_options if: -> { aasm_state == :draft } do |draft|
    draft.validates :category, inclusion: { in: CATEGORIES }, allow_blank: true
    draft.validates :subcategory, inclusion: { in: SPORTS_CARDS }, if: -> { category == 'SPORTS_CARDS' },
                                  allow_blank: true
    draft.validates :subcategory, inclusion: { in: TRADING_CARDS }, if: -> { category == 'TRADING_CARDS' },
                                  allow_blank: true
    draft.validates :subcategory, inclusion: { in: COLLECTIBLES }, if: -> { category == 'COLLECTIBLES' },
                                  allow_blank: true

    draft.validates :condition, inclusion: { in: (2..10).step(2).to_a }, allow_blank: true, allow_nil: true,
                                if: -> { aasm_state == :draft && !grading_company.present? }

    draft.validates :condition, inclusion: { in: (1..10).step(0.5).to_a }, allow_blank: true, allow_nil: true,
                                if: -> { aasm_state == :draft && grading_company.present? }

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

  before_destroy { raise 'Only drafts can be destroyed' unless draft? }

  aasm timestamps: true, no_direct_assignment: true do
    state :draft, initial: true
    state :active, :removed, :reserved, :pending_shipment, :shipped, :sold, :refunded

    event :publish do
      transitions from: %i[draft removed], to: :active
    end

    event :remove do
      transitions from: :active, to: :removed
    end

    event :reserve do
      transitions from: :active, to: :reserved
    end

    event :paid do
      transitions from: :reserved, to: :pending_shipment
    end

    event :ship do
      transitions from: :pending_shipment, to: :shipped
    end

    event :refund do
      transitions from: %i[pending_shipment shipped], to: :refunded
    end
  end
end
