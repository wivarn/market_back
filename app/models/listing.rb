# frozen_string_literal: true

class Listing < ApplicationRecord
  include AASM

  RESERVE_TIME = 15.minutes

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

  with_options if: -> { !draft? } do |active|
    active.validates :account, :photos, :condition, :category, :subcategory, :price, :domestic_shipping,
                     presence: true

    active.validates :category, inclusion: { in: CATEGORIES }
    active.validates :subcategory, inclusion: { in: SPORTS_CARDS }, if: -> { category == 'SPORTS_CARDS' }
    active.validates :subcategory, inclusion: { in: TRADING_CARDS }, if: -> { category == 'TRADING_CARDS' }
    active.validates :subcategory, inclusion: { in: COLLECTIBLES }, if: -> { category == 'COLLECTIBLES' }

    active.validates :condition, inclusion: { in: (2..10).step(2).to_a },
                                 if: -> { !draft? && !grading_company.present? }
    active.validates :condition, inclusion: { in: (1..10).step(0.5).to_a },
                                 if: -> { !draft? && grading_company.present? }

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

  with_options if: -> { draft? } do |draft|
    draft.validates :category, inclusion: { in: CATEGORIES }, allow_blank: true
    draft.validates :subcategory, inclusion: { in: SPORTS_CARDS }, if: -> { category == 'SPORTS_CARDS' },
                                  allow_blank: true
    draft.validates :subcategory, inclusion: { in: TRADING_CARDS }, if: -> { category == 'TRADING_CARDS' },
                                  allow_blank: true
    draft.validates :subcategory, inclusion: { in: COLLECTIBLES }, if: -> { category == 'COLLECTIBLES' },
                                  allow_blank: true

    draft.validates :condition, inclusion: { in: (2..10).step(2).to_a }, allow_blank: true, allow_nil: true,
                                if: -> { draft? && !grading_company.present? }

    draft.validates :condition, inclusion: { in: (1..10).step(0.5).to_a }, allow_blank: true, allow_nil: true,
                                if: -> { draft? && grading_company.present? }

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

  scope :ships_to, lambda { |country|
                     where('shipping_country = :country OR international_shipping IS NOT NULL',
                           country: country)
                   }
  scope :sports_cards, -> { where('category = :category', category: 'SPORTS_CARDS') }
  scope :trading_cards, -> { where('category = :category', category: 'TRADING_CARDS') }
  scope :collectibles, -> { where('category = :category', category: 'COLLECTIBLES') }

  aasm timestamps: true, no_direct_assignment: true do
    state :draft, initial: true
    state :active, :removed, :reserved, :pending_shipment, :shipped, :sold, :refunded

    event :publish do
      transitions from: %i[draft removed], to: :active
    end

    event :remove do
      transitions to: :removed, guard: :active?
    end

    event :reserve do
      transitions to: :reserved, guard: :active?
    end

    event :paid do
      transitions to: :pending_shipment, guard: :reserved?
    end

    event :ship do
      transitions from: :pending_shipment, to: :shipped
    end

    event :refund do
      transitions from: %i[pending_shipment shipped], to: :refunded
    end
  end

  scope :active, lambda {
                   where('aasm_state = ? OR (aasm_state = ? AND reserved_at < ?)', :active, :reserved,
                         Time.now.utc - RESERVE_TIME)
                 }

  scope :reserved, -> { where('aasm_state = ? AND reserved_at >= ?', :reserved, DateTime.now - RESERVE_TIME) }

  def active?
    aasm_state == 'active' || (aasm_state == 'reserved' && reserved_at < Time.now.utc - RESERVE_TIME)
  end

  def reserved?
    aasm_state == 'reserved' && reserved_at >= Time.now.utc - RESERVE_TIME
  end

  def editable?
    draft? || active? || removed?
  end
end
