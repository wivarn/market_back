# frozen_string_literal: true

ivan = Account.create(email: 'ivan@skwirl.io', status: 'verified', given_name: 'Ivan', family_name: 'Wong',
                      currency: 'CAD', role: 'admin')
AccountPasswordHash.create(id: ivan.id, password_hash: BCrypt::Password.create('Password!').to_s)
ivan.addresses.create(street1: '604-1003 Burnaby Street', street2: 'Buzzer 1007', city: 'Vancouver', state: 'BC',
                      zip: 'V6E4R7', country: 'CAN')

ivan.listings.create(photos: ['/images/picture-1.jpg'], category: 'COLLECTIBLES', subcategory: 'WATCHES',
                     title: 'Rolex Submariner Kermit 50th Anniversary Edition Mark VI Ref. 16610T',
                     description: (<<~DESCRIPTION
                       DETAILS
                       Manufacturer: Rolex
                       Model: Submariner Kermit 50th Anniversary
                       Reference Number: 16610LV / 16610T
                       Condition: Good to very good
                       Gender: Men’s/unisex
                       Time Period: 2005 - 2006
                       Retail / Compare-At Price: n/a collector’s item
                       Our Best Price: $18,200"
                     DESCRIPTION
                                  ),
                     condition: 10,
                     price: 18_200,
                     domestic_shipping: 99,
                     international_shipping: 250,
                     currency: 'CAD',
                     status: 'ACTIVE')
ivan.listings.create(photos: ['/images/picture-2.jpg'], category: 'COLLECTIBLES', subcategory: 'WATCHES',
                     title: 'Audemars Piguet Royal Oak Stainless Steel Blue Index Dial Watch 15400ST.OO.1220ST.03',
                     description: (<<~DESCRIPTION
                       Razor-sharp and understated, this Royal Oak ref. 15400ST.OO.1220ST.03 is classic Audemars Piguet. The timepiece has a beautifully finished stainless-steel case and matching bracelet, a staple for the inimitable Royal Oak. However, itâ€s the galvanized blue â€œGrande Tapisserieâ€ dial that bolsters the visuals of the timepiece. It pops against the immaculate hand-finishing of the case and bracelet. The watch also features a sapphire crystal caseback, quick-set date functionality, and the selfwinding mechanical calibre 3120.

                       Free Domestic Shipping via Insured FedEx Overnight
                     DESCRIPTION
                                  ),
                     condition: 8,
                     price: 50_125,
                     domestic_shipping: 0,
                     international_shipping: 0,
                     currency: 'CAD',
                     status: 'ACTIVE')
ivan.listings.create(photos: ['/images/picture-3.jpg'], category: 'COLLECTIBLES', subcategory: 'WATCHES',
                     title: 'Patek Philippe Nautilus Stainless Steel Blue Index Dial Watch 5980/1A-001',
                     description: (<<~DESCRIPTION
                       The Patek Philippe Nautilus was first introduced in 1978 at a time when watch cases were getting thinner, the Nautilus flew against this trend and soon became one of the brand's most iconic models. This exquisite Patek Philippe 5980/1A-001 case is made of stainless-steel and measures 40.5 mm in diameter and is 12.2mm thick. The dial of this Patek Philippe Nautilus Chronograph is blue-black and features luminescent, hour markers, a chronograph sub-dial at 6 o'clock and a date display in the 3 o'clock position. The 5980/1A-001 is powered by the self-winding Caliber CH 28â€‘520 C with chronograph functionality and a maximum 55-hour power reserve. It comes with a stainless-steel bracelet with a fold-over clasp. It has a water resistance of 100 meters (330 feet).

                       This watch comes with its Original Factory Box and Papers.


                       Free Domestic Shipping via Insured FedEx Overnight


                       • 14-day money back guarantee. The buyer can authenticate the watch at any boutique or dealership within 14 days
                       • 2-year warranty on all our watches
                       • Our watches are always on hand. If you have any questions or require additional images, please contact us.
                       • *Please note that all International buyers are responsible for custom taxes/duties of the receiving country. We do not defraud Customs.
                       • *Customers will be charged taxes according to the rules and regulations of their state.
                     DESCRIPTION
                                  ),
                     condition: 10,
                     price: 180_975,
                     domestic_shipping: 0,
                     currency: 'CAD',
                     status: 'DRAFT')

kevin = Account.create(email: 'kevin@skwirl.io', status: 'verified', given_name: 'Kevin', family_name: 'Legere',
                       currency: 'USD', role: 'admin')
AccountPasswordHash.create(id: kevin.id, password_hash: BCrypt::Password.create('Password!').to_s)
kevin.addresses.create(street1: '930 Lodge', city: 'Victoria', state: 'BC', zip: 'V8X3A8', country: 'CAN')

kevin.listings.create(photos: ['/images/picture-4.jpg'], category: 'TRADING_CARDS', subcategory: 'MAGIC',
                      title: 'Black Lotus (Alpha) - BGS GEM MINT 9.5 MTG',
                      grading_company: 'BGS',
                      condition: 9.5,
                      price: 799_999,
                      domestic_shipping: 99,
                      international_shipping: 99,
                      currency: 'USD',
                      status: 'ACTIVE')
kevin.listings.create(photos: ['/images/picture-5.jpg'], category: 'TRADING_CARDS', subcategory: 'MAGIC',
                      title: 'MTG Magic Alpha Time Walk BGS 9.5 B GEM MINT (TCC)',
                      grading_company: 'BGS',
                      condition: 9.5,
                      price: 38_999,
                      domestic_shipping: 0,
                      international_shipping: 0,
                      currency: 'USD',
                      status: 'ACTIVE')
kevin.listings.create(photos: ['/images/picture-1.jpg'], category: 'TRADING_CARDS', subcategory: 'MAGIC',
                      title: '1993 Magic The Gathering MTG Beta Mox Ruby PSA 4 VGEX',
                      grading_company: 'PSA',
                      condition: 4,
                      price: 1581,
                      domestic_shipping: 0,
                      international_shipping: 0,
                      currency: 'USD',
                      status: 'DRAFT')
