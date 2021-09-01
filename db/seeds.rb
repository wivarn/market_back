# frozen_string_literal: true

ivan = Account.create(email: 'ivan@skwirl.io', status: 'verified', given_name: 'Ivan', family_name: 'Wong',
                      currency: 'CAD', role: 'admin')
AccountPasswordHash.create(id: ivan.id, password_hash: BCrypt::Password.create('Password!').to_s)
ivan.create_address(street1: '604-1003 Burnaby Street', street2: 'Buzzer 1007', city: 'Vancouver', state: 'BC',
                    zip: 'V6E4R7', country: 'CAN')

kevin = Account.create(email: 'kevin@skwirl.io', status: 'verified', given_name: 'Kevin', family_name: 'Legere',
                       currency: 'USD', role: 'admin')
AccountPasswordHash.create(id: kevin.id, password_hash: BCrypt::Password.create('Password!').to_s)
kevin.create_address(street1: '930 Lodge', city: 'Victoria', state: 'BC', zip: 'V8X3A8', country: 'CAN')

test1 = Account.create(email: 'test1@skwirl.io', status: 'verified', given_name: 'Test1', family_name: 'User',
                       currency: 'CAD')
AccountPasswordHash.create(id: test1.id, password_hash: BCrypt::Password.create('Password!').to_s)
test1.create_address(street1: '123 Test St', city: 'Fakecity', state: 'BC', zip: 'V0X0X0', country: 'CAN')

test2 = Account.create(email: 'test2@skwirl.io', status: 'verified', given_name: 'Test2', family_name: 'User',
                       currency: 'USD')
AccountPasswordHash.create(id: test2.id, password_hash: BCrypt::Password.create('Password!').to_s)
test2.create_address(street1: '777 Test Ave', city: 'Fakevillage', state: 'AB', zip: 'C1X1X1', country: 'CAN')
