account = Account.create(email: 'ivan@skwirl.io', status: 'verified', given_name: 'Ivan', family_name: 'Wong', currency: 'CAD',
                         role: 'admin')
AccountPasswordHash.create(id: account.id, password_hash: BCrypt::Password.create('Password!').to_s)

account = Account.create(email: 'kevin@skwirl.io', status: 'verified', given_name: 'Kevin', family_name: 'Legere', currency: 'USD',
                         role: 'admin')
AccountPasswordHash.create(id: account.id, password_hash: BCrypt::Password.create('Password!').to_s)
