# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_table-setter_session',
  :secret      => '5e6bb14c8aa614d772836022e5e449c3192c1781e1da8e3b464762e9c3bc8d4f9d47cb2a27cc6f15b1109596f30fcd36cf20e2537ab585b412acea26a481a1b0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
