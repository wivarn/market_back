# frozen_string_literal: true

ivan = Account.create(email: 'ivan@skwirl.io', status: 'verified', given_name: 'Ivan', family_name: 'Wong',
                      currency: 'CAD', role: 'admin')
AccountPasswordHash.create(id: ivan.id, password_hash: BCrypt::Password.create('Password!').to_s)
ivan.addresses.create(street1: '604-1003 Burnaby Street', street2: 'Buzzer 1007', city: 'Vancouver', state: 'BC',
                      zip: 'V6E4R7', country: 'CAN')

collectibles = JSON.parse(File.read('db/seeds/collectibles_1.json'))
ivan.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(collectibles)
sports_cards = JSON.parse(File.read('db/seeds/sports_cards_1.json'))
ivan.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(sports_cards)
trading_cards = JSON.parse(File.read('db/seeds/trading_cards_1.json'))
ivan.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(trading_cards)

kevin = Account.create(email: 'kevin@skwirl.io', status: 'verified', given_name: 'Kevin', family_name: 'Legere',
                       currency: 'USD', role: 'admin')
AccountPasswordHash.create(id: kevin.id, password_hash: BCrypt::Password.create('Password!').to_s)
kevin.addresses.create(street1: '930 Lodge', city: 'Victoria', state: 'BC', zip: 'V8X3A8', country: 'CAN')

collectibles = JSON.parse(File.read('db/seeds/collectibles_2.json'))
kevin.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(collectibles)
sports_cards = JSON.parse(File.read('db/seeds/sports_cards_2.json'))
kevin.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(sports_cards)
trading_cards = JSON.parse(File.read('db/seeds/trading_cards_2.json'))
kevin.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(trading_cards)
