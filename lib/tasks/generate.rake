# frozen_string_literal: true

STUB_PHOTOS = [
  '/images/picture-1.jpg',
  '/images/picture-2.jpg',
  '/images/picture-3.jpg',
  '/images/picture-4.jpg',
  '/images/picture-5.jpg'
].freeze

namespace :generate do
  task all: :environment do
    Rake::Task['generate:sports_cards'].invoke
    Rake::Task['generate:trading_cards'].invoke
    Rake::Task['generate:collectibles'].invoke
  end

  task sports_cards: :environment do
    listings = []
    50.times do
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'SPORTS_CARDS',
        subcategory: 'BASKETBALL',
        title: Faker::Sports::Basketball.player,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'USD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: 'ACTIVE'
      }
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'SPORTS_CARDS',
        subcategory: 'FOOTBALL',
        title: Faker::Sports::Football.player,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'USD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: 'ACTIVE'
      }
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'SPORTS_CARDS',
        subcategory: 'HOCKEY',
        title: Faker::Name.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'USD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: 'ACTIVE'
      }
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'SPORTS_CARDS',
        subcategory: Listing::SPORTS_CARDS.sample,
        title: Faker::Name.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'USD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: 'DRAFT'
      }
    end
    open('db/seeds/sports_cards.json', 'w+') { |f| f << listings.to_json }
  end

  task trading_cards: :environment do
    listings = []
    50.times do
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'TRADING_CARDS',
        subcategory: 'POKEMON',
        title: Faker::Games::Pokemon.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'CAD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: 'ACTIVE'
      }
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'TRADING_CARDS',
        subcategory: 'DRAGON_BALL_SUPER',
        title: Faker::JapaneseMedia::DragonBall.character,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'CAD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: 'ACTIVE'
      }
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'TRADING_CARDS',
        subcategory: 'STAR_WARS_DESTINY',
        title: Faker::Movies::StarWars.character,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'CAD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: 'ACTIVE'
      }
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'TRADING_CARDS',
        subcategory: Listing::TRADING_CARDS.sample,
        title: Faker::Name.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'CAD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: 'DRAFT'
      }
    end
    open('db/seeds/trading_cards.json', 'w+') { |f| f << listings.to_json }
  end

  task collectibles: :environment do
    listings = []
    50.times do
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: 'TOYS',
        title: "#{Faker::Superhero.descriptor} #{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'CAD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: 'ACTIVE'
      }
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: 'ART',
        title: Faker::Artist.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'CAD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: nil,
        status: 'ACTIVE'
      }
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: 'STAMPS',
        title: "#{Faker::Address.community} #{Faker::Address.city} #{Faker::Address.country}",
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'CAD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: 'ACTIVE'
      }
      listings << {
        photos: STUB_PHOTOS.sample(rand(1..5)),
        category: 'COLLECTIBLES',
        subcategory: Listing::COLLECTIBLES.sample,
        title: Faker::Name.name,
        description: Faker::Lorem.paragraphs(number: Faker::Number.between(from: 1, to: 10)).join("\n"),
        grading_company: Listing::GRADING_COMPANIES.sample,
        condition: (1..10).step(0.5).to_a.sample,
        currency: 'CAD',
        price: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 6), r_digits: 2),
        domestic_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 1, to: 2), r_digits: 2),
        international_shipping: Faker::Number.decimal(l_digits: Faker::Number.between(from: 2, to: 3), r_digits: 2),
        status: 'DRAFT'
      }
    end
    open('db/seeds/collectibles.json', 'w+') { |f| f << listings.to_json }
  end
end
