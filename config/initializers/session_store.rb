# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_table-setter-rack_session',
  :secret      => '3aa29a6572aebdd3d60ef08834ac2dbb5613ef1186106ff14c664a6ba427b97897a24d2f4c910edfbd2a4798e4365910879d11fb6c9bf5db6bc520f770065165'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
