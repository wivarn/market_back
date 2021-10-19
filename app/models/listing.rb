# frozen_string_literal: true

class Listing < ApplicationRecord
  include AASM
  include PgSearch::Model

  attr_writer :combined, :destination_country

  RESERVE_TIME = 1.hour
  CATEGORIES = %w[SPORTS_CARDS TRADING_CARDS COLLECTIBLES].freeze
  SPORTS_CARDS = %w[BASEBALL BASKETBALL FOOTBALL HOCKEY OTHER].freeze
  TRADING_CARDS = %w[MAGIC POKEMON OTHER].freeze
  COLLECTIBLES = %w[COMICS GAMES TOYS OTHER].freeze
  GRADING_COMPANIES = %w[BGS CSG HGA KSA MNT PSA SGC OTHER].freeze

  mount_uploaders :photos, ImageUploader

  pg_search_scope :search, against: {
    title: 'A',
    description: 'B'
  }, using: {
    tsearch: { dictionary: 'english' }
  }, order_within_rank: 'listings.updated_at DESC'

  validates :account, :title, :currency, :shipping_country, :accept_offers, presence: true
  validates :title, length: { in: 2..256 }
  validates :currency, inclusion: { in: %w[USD CAD] }
  validates :shipping_country, inclusion: { in: %w[USA CAN] }
  validates :grading_company, inclusion: { in: GRADING_COMPANIES }, allow_nil: true, allow_blank: true
  validates :international_shipping, :combined_shipping,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 100_000_000
            }, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ },
            allow_nil: true, allow_blank: false

  with_options if: -> { !draft? } do |not_draft|
    not_draft.validates :account, :photos, :condition, :category, :subcategory, :price, :domestic_shipping,
                        presence: true

    not_draft.validates :category, inclusion: { in: CATEGORIES }
    not_draft.validates :subcategory, inclusion: { in: SPORTS_CARDS }, if: -> { category == 'SPORTS_CARDS' }
    not_draft.validates :subcategory, inclusion: { in: TRADING_CARDS }, if: -> { category == 'TRADING_CARDS' }
    not_draft.validates :subcategory, inclusion: { in: COLLECTIBLES }, if: -> { category == 'COLLECTIBLES' }

    not_draft.validates :condition, inclusion: { in: (2..10).step(2).to_a },
                                    if: -> { !draft? && !grading_company.present? }
    not_draft.validates :condition, inclusion: { in: (1..10).step(0.5).to_a },
                                    if: -> { !draft? && grading_company.present? }

    not_draft.validates :price, :domestic_shipping, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ },
                                                    allow_blank: false
    not_draft.validates :price, numericality: {
      greater_than_or_equal_to: 1,
      less_than: 100_000_000
    }
    not_draft.validates :domestic_shipping, numericality: {
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
  has_many :offers, dependent: :destroy

  alias_attribute :seller, :account

  before_destroy { raise 'Only drafts can be destroyed' unless draft? }

  scope :ships_to, lambda { |country|
                     return self unless %w[USA CAN].include?(country)

                     where('shipping_country = :country OR international_shipping IS NOT NULL',
                           country: country)
                   }
  scope :sports_cards, -> { where('category = :category', category: 'SPORTS_CARDS') }
  scope :trading_cards, -> { where('category = :category', category: 'TRADING_CARDS') }
  scope :collectibles, -> { where('category = :category', category: 'COLLECTIBLES') }

  aasm timestamps: true, no_direct_assignment: true do
    state :draft, initial: true
    state :active, :removed, :reserved, :sold

    event :publish do
      transitions from: %i[draft removed], to: :active
    end

    event :remove do
      transitions to: :removed, guard: :active?
    end

    event :reserve do
      transitions to: :reserved, guard: :active?
    end

    event :cancel_reservation do
      transitions from: :reserved, to: :active
    end

    event :paid do
      transitions to: :sold, guard: :reserved?
    end
  end

  scope :active, lambda {
                   where('aasm_state = ? OR (aasm_state = ? AND reserved_at < ?)', :active, :reserved,
                         Time.now.utc - RESERVE_TIME)
                 }

  scope :reserved, -> { where('aasm_state = ? AND reserved_at >= ?', :reserved, DateTime.now - RESERVE_TIME) }
  scope :publically_viewable, -> { where.not(aasm_state: %w[draft removed]) }

  def active?
    aasm_state == 'active' || (aasm_state == 'reserved' && reserved_at < Time.now.utc - RESERVE_TIME)
  end

  def reserved?
    aasm_state == 'reserved' && reserved_at >= Time.now.utc - RESERVE_TIME
  end

  def editable?
    draft? || active? || removed?
  end

  # Blueprint can pass destination_country in as nil
  def shipping(destination_country: nil, combined: false)
    @combined ||= combined
    @destination_country ||= destination_country
    dest_shipping = if @destination_country == shipping_country || @destination_country.blank?
                      domestic_shipping
                    else
                      international_shipping
                    end
    @combined ? [combined_shipping, dest_shipping].compact.min : dest_shipping
  end
end
