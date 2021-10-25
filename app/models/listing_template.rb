class ListingTemplate < ApplicationRecord
  SPORTS_CARDS = %w[HOCKEY BASEBALL BASKETBALL FOOTBALL SOCCER OTHER].freeze
  TRADING_CARDS = %w[CARDFIGHT_VANGUARD DRAGON_BALL_SUPER FLESH_AND_BLOOD MAGIC POKEMON STAR_WARS_DESTINY YUGIOH
                     OTHER].freeze
  COLLECTIBLES = %w[ANTIQUES ART COINS COMICS STAMPS TOYS WATCHES OTHER].freeze
  GRADING_COMPANIES = %w[BGS CSG HGA KSA MNT PSA SGC OTHER].freeze

  validates :account, :accept_offers, presence: true
  validates :title, length: { in: 2..256 }, allow_nil: true, allow_blank: true

  validates :category, inclusion: { in: %w[SPORTS_CARDS TRADING_CARDS COLLECTIBLES] }, allow_nil: true
  validates :subcategory, inclusion: { in: SPORTS_CARDS }, if: -> { category == 'SPORTS_CARDS' }, allow_nil: true
  validates :subcategory, inclusion: { in: TRADING_CARDS }, if: -> { category == 'TRADING_CARDS' }, allow_nil: true
  validates :subcategory, inclusion: { in: COLLECTIBLES }, if: -> { category == 'COLLECTIBLES' }, allow_nil: true

  validates :grading_company, inclusion: { in: GRADING_COMPANIES }, allow_nil: true
  validates :condition, inclusion: { in: (2..10).step(2).to_a }, if: -> { grading_company.nil? }, allow_nil: true
  validates :condition, inclusion: { in: (1..10).step(0.5).to_a }, if: -> { !grading_company.nil? }, allow_nil: true

  validates :price,
            :domestic_shipping, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ }, allow_nil: true, allow_blank: false
  validates :price, numericality: {
    greater_than_or_equal_to: 0.25,
    less_than: 100_000_000
  }, allow_nil: true, allow_blank: false
  validates :domestic_shipping, numericality: {
    greater_than_or_equal_to: 0,
    less_than: 100_000_000
  }, allow_nil: true, allow_blank: false
  validates :international_shipping, :combined_shipping,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 100_000_000
            }, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ },
            allow_nil: true, allow_blank: false

  belongs_to :account
end
