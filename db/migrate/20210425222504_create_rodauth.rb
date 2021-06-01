class CreateRodauth < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'citext'

    create_table :accounts do |t|
      t.citext :email, null: false, index: { unique: true, where: "status IN ('unverified', 'verified')" }
      t.string :status, null: false, default: 'unverified'
      t.string :given_name, null: false
      t.string :family_name, null: false
      t.string :picture
      t.string :currency, null: false, limit: 3, default: 'USD'
      t.string :role, null: false, default: 'user'
    end

    # Used if storing password hashes in a separate table (default)
    create_table :account_password_hashes do |t|
      t.foreign_key :accounts, column: :id
      t.string :password_hash, null: false
    end

    # Used by the password reset feature
    create_table :account_password_reset_keys do |t|
      t.foreign_key :accounts, column: :id
      t.string :key, null: false
      t.datetime :deadline, null: false
      t.datetime :email_last_sent, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # Used by the disallow_password_reuse feature
    create_table :account_previous_password_hashes do |t|
      t.references :account, foreign_key: true
      t.string :password_hash, null: false
    end

    # Used by the account verification feature
    create_table :account_verification_keys do |t|
      t.foreign_key :accounts, column: :id
      t.string :key, null: false
      t.datetime :requested_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :email_last_sent, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # Used by the verify login change feature
    create_table :account_login_change_keys do |t|
      t.foreign_key :accounts, column: :id
      t.string :key, null: false
      t.string :login, null: false
      t.datetime :deadline, null: false
    end

    # Used by the lockout feature
    create_table :account_login_failures do |t|
      t.foreign_key :accounts, column: :id
      t.integer :number, null: false, default: 1
    end
    create_table :account_lockouts do |t|
      t.foreign_key :accounts, column: :id
      t.string :key, null: false
      t.datetime :deadline, null: false
      t.datetime :email_last_sent
    end

    # Used by the jwt refresh feature
    create_table :account_jwt_refresh_keys do |t|
      t.references :account, foreign_key: true, null: false, column: :id
      t.string :key, null: false
      t.datetime :deadline, null: false, default: -> { "CURRENT_TIMESTAMP + (14 ||' days')::interval" }
      t.index :account_id, name: 'account_jwt_rk_account_id_idx'
    end

    # Used by the active sessions feature
    create_table :account_active_session_keys, primary_key: %i[account_id session_id] do |t|
      t.references :account, foreign_key: true
      t.string :session_id
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :last_use, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # Used by the otp feature
    create_table :account_otp_keys do |t|
      t.foreign_key :accounts, column: :id
      t.string :key, null: false
      t.integer :num_failures, null: false, default: 0
      t.datetime :last_use, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # Used by the recovery codes feature
    create_table :account_recovery_codes, primary_key: %i[id code] do |t|
      t.column :id, :bigint
      t.foreign_key :accounts, column: :id
      t.string :code
    end

    # Used by the audit logging feature
    create_table :account_authentication_audit_logs do |t|
      t.references :account, foreign_key: true, null: false
      t.datetime :at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.text :message, null: false
      t.jsonb :metadata

      t.index %i[account_id at], name: 'audit_account_at_idx'
      t.index :at, name: 'audit_at_idx'
    end
  end
end
