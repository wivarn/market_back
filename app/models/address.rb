class Address < ApplicationRecord
  STATE_CODES = %w[
    AL AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO
    MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY
  ].freeze

  PROVINCE_CODES = %w[AB BC MB NB NL NT NS NU ON PE QC SK YT].freeze

  belongs_to :account, dependent: :destroy

  validates :street1, :city, :state, :zip, :country, presence: true
  validates :street1, :city, length: { in: 1..100 }
  validates :street2, length: { maximum: 100 }
  validates :country, inclusion: { in: %w[USA CAN] }
  validates :state, inclusion: { in: STATE_CODES, message: 'invalid state' }, if: -> { country == 'USA' }
  validates :state, inclusion: { in: PROVINCE_CODES, message: 'invalid province' }, if: -> { country == 'CAN' }
  validates :zip, format: { with: /\A\d{5}\z/, message: 'invalid zip code' }, if: -> { country == 'USA' }
  validates :zip, format: { with: /\A[A-Z]\d[A-Z]\d[A-Z]\d\z/,
                            message: 'invalid postal code' }, if: -> { country == 'CAN' }
end
