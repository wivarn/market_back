# frozen_string_literal: true

STUB_PHOTOS = [
  '/images/picture-1.jpg',
  '/images/picture-2.jpg',
  '/images/picture-3.jpg',
  '/images/picture-4.jpg',
  '/images/picture-5.jpg'
].freeze

def generate_listings(items: 50, currency: 'CAD', subcategories: [], status: 'ACTIVE')
  listings = []
  items.times do
    if subcategories.include?('BASKETBALL')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'SPORTS_CARDS',
        subcategory: 'BASKETBALL',
        title: Faker::Sports::Basketball.player,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: status
      }
    end
    if subcategories.include?('FOOTBALL')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'SPORTS_CARDS',
        subcategory: 'FOOTBALL',
        title: Faker::Sports::Football.player,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: status
      }
    end
    if subcategories.include?('HOCKEY')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'SPORTS_CARDS',
        subcategory: 'HOCKEY',
        title: Faker::Name.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: nil,
        condition: (2..10).step(2).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: status
      }
    end
    if subcategories.include?('RANDOM_SPORTS')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'SPORTS_CARDS',
        subcategory: Listing::SPORTS_CARDS.sample,
        title: Faker::Name.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: status
      }
    end
    if subcategories.include?('POKEMON')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'TRADING_CARDS',
        subcategory: 'POKEMON',
        title: Faker::Games::Pokemon.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: status
      }
    end
    if subcategories.include?('DRAGON_BALL_SUPER')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'TRADING_CARDS',
        subcategory: 'DRAGON_BALL_SUPER',
        title: Faker::JapaneseMedia::DragonBall.character,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: status
      }
    end
    if subcategories.include?('STAR_WARS_DESTINY')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'TRADING_CARDS',
        subcategory: 'STAR_WARS_DESTINY',
        title: Faker::Movies::StarWars.character,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: nil,
        condition: (2..10).step(2).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: status
      }
    end
    if subcategories.include?('RANDOM_TRADING')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'TRADING_CARDS',
        subcategory: Listing::TRADING_CARDS.sample,
        title: Faker::Name.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: status
      }
    end
    if subcategories.include?('TOYS')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: 'TOYS',
        title: "#{Faker::Superhero.descriptor} #{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: status
      }
    end
    if subcategories.include?('ART')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: 'ART',
        title: Faker::Artist.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: status
      }
    end
    if subcategories.include?('STAMPS')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: 'STAMPS',
        title: "#{Faker::Address.community} #{Faker::Address.city} #{Faker::Address.country}",
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: status
      }
    end
    next unless subcategories.include?('RANDOM_COLLECTIBLES')

    listings << {
      photos: STUB_PHOTOS.sample(rand(1..5)),
      category: 'COLLECTIBLES',
      subcategory: Listing::COLLECTIBLES.sample,
      title: Faker::Name.name,
      description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
      grading_company: Listing::GRADING_COMPANIES.sample,
      condition: (1..10).step(0.5).to_a.sample,
      currency: currency,
      price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
      domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
      international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
      status: status
    }
  end
  listings
end

ivan = Account.create(email: 'ivan@skwirl.io', status: 'verified', given_name: 'Ivan', family_name: 'Wong',
                      currency: 'CAD', role: 'admin')
AccountPasswordHash.create(id: ivan.id, password_hash: BCrypt::Password.create('Password!').to_s)
ivan.addresses.create(street1: '604-1003 Burnaby Street', street2: 'Buzzer 1007', city: 'Vancouver', state: 'BC',
                      zip: 'V6E4R7', country: 'CAN')

active_listings = generate_listings(subcategories: %w[TOYS STAMPS ART RANDOM_COLLECTIBLES POKEMON DRAGON_BALL_SUPER],
                                    status: 'ACTIVE')
ivan.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(active_listings)
draft_listings = generate_listings(items: 20, subcategories: %w[ART RANDOM_COLLECTIBLES], status: 'DRAFT')
ivan.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(draft_listings)

kevin = Account.create(email: 'kevin@skwirl.io', status: 'verified', given_name: 'Kevin', family_name: 'Legere',
                       currency: 'USD', role: 'admin')
AccountPasswordHash.create(id: kevin.id, password_hash: BCrypt::Password.create('Password!').to_s)
kevin.addresses.create(street1: '930 Lodge', city: 'Victoria', state: 'BC', zip: 'V8X3A8', country: 'CAN')

active_listings = generate_listings(currency: 'USD',
                                    subcategories: %w[BASKETBALL FOOTBALL HOCKEY RANDOM_SPORTS POKEMON
                                                      STAR_WARS_DESTINY],
                                    status: 'ACTIVE')
kevin.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(active_listings)
draft_listings = generate_listings(items: 20, subcategories: %w[HOCKEY RANDOM_SPORTS RANDOM_TRADING], status: 'DRAFT')
kevin.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(draft_listings)
