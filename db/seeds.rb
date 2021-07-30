# frozen_string_literal: true

STUB_PHOTOS = [
  '/images/picture-1.jpg',
  '/images/picture-2.jpg',
  '/images/picture-3.jpg',
  '/images/picture-4.jpg',
  '/images/picture-5.jpg'
].freeze

def generate_sports_image
  images = []
  Faker::Number.between(from: 1, to: 10).times do
    images << Faker::LoremPixel.image(
      size: "#{Faker::Number.between(from: 100, to: 1000)}x#{Faker::Number.between(from: 100, to: 1000)}",
      is_gray: false, category: 'sports', secure: !(Jets.env.development? || Jets.env.test?)
    )
  end
  images
end

def generate_listings(items: 100, currency: 'CAD', shipping_country: 'CAN', subcategories: [], aasm_state: :active, combined_shipping: 1)
  listings = []
  items.times do
    if subcategories.include?('BASKETBALL')
      listings << {
        photos: generate_sports_image,
        category: 'SPORTS_CARDS',
        subcategory: 'BASKETBALL',
        title: "#{Faker::Number.within(range: 1930..2021)} #{Faker::Sports::Basketball.player} #{Faker::Sports::Basketball.team} #{Faker::Sports::Basketball.position}",
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
      }
    end
    if subcategories.include?('FOOTBALL')
      listings << {
        photos: generate_sports_image,
        category: 'SPORTS_CARDS',
        subcategory: 'FOOTBALL',
        title: "#{Faker::Number.within(range: 1930..2021)} #{Faker::Sports::Football.player} #{Faker::Sports::Football.team} #{Faker::Sports::Football.position}",
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
      }
    end
    if subcategories.include?('HOCKEY')
      listings << {
        photos: generate_sports_image,
        category: 'SPORTS_CARDS',
        subcategory: 'HOCKEY',
        title: Faker::Name.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: nil,
        condition: (2..10).step(2).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
      }
    end
    if subcategories.include?('RANDOM_SPORTS')
      listings << {
        photos: generate_sports_image,
        category: 'SPORTS_CARDS',
        subcategory: Listing::SPORTS_CARDS.sample,
        title: "#{Faker::Esport.game} #{Faker::Esport.team} #{Faker::Esport.player} #{Faker::Esport.league} #{Faker::Esport.event}",
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
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
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
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
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
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
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
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
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
      }
    end
    if subcategories.include?('TOYS')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: 'TOYS',
        title: "#{Faker::Superhero.descriptor} #{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: nil,
        condition: (2..10).step(2).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
      }
    end
    if subcategories.include?('ART')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: 'ART',
        title: Faker::Artist.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: nil,
        condition: (2..10).step(2).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
      }
    end
    if subcategories.include?('STAMPS')
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: 'STAMPS',
        title: "#{Faker::Address.community} #{Faker::Address.city} #{Faker::Address.country}",
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: nil,
        condition: (2..10).step(2).to_a.sample,
        currency: currency,
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        shipping_country: shipping_country,
        aasm_state: aasm_state,
        combined_shipping: combined_shipping
      }
    end
    next unless subcategories.include?('RANDOM_COLLECTIBLES')

    listings << {
      photos: STUB_PHOTOS.sample(rand(1..5)),
      category: 'COLLECTIBLES',
      subcategory: Listing::COLLECTIBLES.sample,
      title: Faker::Lorem.sentence(word_count: 5, supplemental: true, random_words_to_add: 10),
      description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
      grading_company: nil,
      condition: (2..10).step(2).to_a.sample,
      currency: currency,
      price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 6), r_digits: 2),
      domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
      international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
      shipping_country: shipping_country,
      aasm_state: aasm_state,
      combined_shipping: combined_shipping
    }
  end
  listings
end

ivan = Account.create(email: 'ivan@skwirl.io', status: 'verified', given_name: 'Ivan', family_name: 'Wong',
                      currency: 'CAD', role: 'admin')
AccountPasswordHash.create(id: ivan.id, password_hash: BCrypt::Password.create('Password!').to_s)
ivan.create_address(street1: '604-1003 Burnaby Street', street2: 'Buzzer 1007', city: 'Vancouver', state: 'BC',
                    zip: 'V6E4R7', country: 'CAN')

# active_listings = generate_listings(subcategories: %w[TOYS STAMPS ART RANDOM_COLLECTIBLES POKEMON DRAGON_BALL_SUPER],
#                                     aasm_state: :active)
# ivan.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(active_listings)
# draft_listings = generate_listings(subcategories: %w[ART RANDOM_COLLECTIBLES], aasm_state: :draft,
#                                    shipping_country: 'USA')
# ivan.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(draft_listings)

kevin = Account.create(email: 'kevin@skwirl.io', status: 'verified', given_name: 'Kevin', family_name: 'Legere',
                       currency: 'USD', role: 'admin')
AccountPasswordHash.create(id: kevin.id, password_hash: BCrypt::Password.create('Password!').to_s)
kevin.create_address(street1: '930 Lodge', city: 'Victoria', state: 'BC', zip: 'V8X3A8', country: 'CAN')

# active_listings = generate_listings(currency: 'USD',
#                                     subcategories: %w[BASKETBALL FOOTBALL HOCKEY RANDOM_SPORTS POKEMON
#                                                       STAR_WARS_DESTINY],
#                                     aasm_state: :active,
#                                     shipping_country: 'USA',
#                                     combined_shipping: 2.04)
# kevin.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(active_listings)
# draft_listings = generate_listings(subcategories: %w[HOCKEY RANDOM_SPORTS RANDOM_TRADING], aasm_state: :draft,
#                                    combined_shipping: 2.86)
# kevin.listings.create_with(created_at: Time.now, updated_at: Time.now).insert_all(draft_listings)

test1 = Account.create(email: 'test1@skwirl.io', status: 'verified', given_name: 'Test1', family_name: 'User',
                       currency: 'CAD')
AccountPasswordHash.create(id: test1.id, password_hash: BCrypt::Password.create('Password!').to_s)
test1.create_address(street1: '123 Test St', city: 'Fakecity', state: 'BC', zip: 'V0X0X0', country: 'CAN')

test2 = Account.create(email: 'test2@skwirl.io', status: 'verified', given_name: 'Test2', family_name: 'User',
                       currency: 'USD')
AccountPasswordHash.create(id: test2.id, password_hash: BCrypt::Password.create('Password!').to_s)
test2.create_address(street1: '777 Test Ave', city: 'Fakevillage', state: 'AB', zip: 'C1X1X1', country: 'CAN')
