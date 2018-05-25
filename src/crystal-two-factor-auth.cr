require "./crystal-two-factor-auth/*"
require "crystal-base32"

# Crystal implementation for the Time-based One-Time PAssword (TOTP) two factor authentication algorithm.
# To get this to work you:
# 1. Use generate_base32_secret() to generate a secret key for a user
# 2. Store the secret key in the database associated with the user account
# 3. Display the QR image URL returned by qrImageUrl(...) to the user
# 4. User uses the image to load the secrey key into his authenticator application
#
# Whenever the user logs in:
#
# 1. The user enters the numnber from the authenticator application into the login form
# 2. Read the secret associated with the user account from the database
# 3. The server compares theuser input with the output form generate_current_number(...)
# 4. If they are equal then the user is allowed to log in
#
# See: https://github.com/SushiChain/crystal-two-factor-auth
#
# For more details about this magic algorithm, see: http://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm
class TimeBasedOneTimePasswordUtil
  # default time-step which is part of the spec, 30 seconds is default
  DEFAULT_TIME_STEP_SECONDS = 30

  # set to the number of digits to control 0 prefix, set to 0 for no prefix
  NUM_DIGITS_OUTPUT = 6

  # Generate and return a 16-character secret key in base32 format (A-Z2-7) using cystal-base32. Could be used
  # to generate the QR image to be shared with the user. Other lengths should use generate_base32_secret(Int32).
  def generate_base32_secret(length : Int32 = 16)
    Base32.random_base32(length)
  end

  def validate_current_number(base32_secret : String, auth_number : Int32, window_millis : Int32, time_millis : Int64 = Time.now.epoch_ms, time_step_seconds : Int32 = DEFAULT_TIME_STEP_SECONDS)
  end

  def generate_number(base32_secret : String, time_millis : Int64, time_step_seconds : Int32)
  end
end
