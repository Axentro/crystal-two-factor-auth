require "./crystal-two-factor-auth/*"
require "crystal-base32"
require "openssl/hmac"

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
class TOTP
  # default time-step which is part of the spec, 30 seconds is default
  DEFAULT_TIME_STEP_SECONDS = 30

  # Generate and return a 16-character secret key in base32 format (A-Z2-7) using cystal-base32. Could be used
  # to generate the QR image to be shared with the user. Other lengths should use generate_base32_secret(Int32).
  def self.generate_base32_secret(length : Int32 = 16)
    Base32.random_base32(length)
  end

  # Validates if the auth number supplied matches the code generated from the base32_secret
  # By default it works on the current time and uses the default time step
  # * base32_secret: Secret string encoded using base-32 that was used to generate the QR code or shared with the user.
  # * auth_number: Time based number provided by the user from their authenticator application.
  # * window_millis: Number of milliseconds that they are allowed to be off and still match. This checks before and after the current time to account for clock variance. Set to 0 for no window. Defaults to 10 seconds
  # * time_millis: Time in milliseconds.
  # * time_step_seconds: Time step in seconds. The default value is 30 seconds here
  def self.validate_number_string(base32_secret : String, auth_number : String, window_millis : Int32 = 10000, time_millis : Int64 = Time.now.epoch_ms, time_step_seconds : Int32 = DEFAULT_TIME_STEP_SECONDS)
    return false if base32_secret.empty? || auth_number.empty?
    from = time_millis
    to = time_millis
    if window_millis > 0
      from -= window_millis
      to += window_millis
    end
    time_step_millis = time_step_seconds * 1000
    millis = from
    while millis <= to
      compare = generate_number_string(base32_secret, millis, time_step_seconds)
      return true if compare == auth_number
      millis += time_step_millis
    end
    false
  end

  # Generate the authenticator number that is shown in the users app e.g. Google authenticator or Authy
  # By default returns the current number but a time and time step can also be supplied.
  # The returned number is zero padded if required.
  def self.generate_number_string(base32_secret : String, time_millis : Int64 = Time.now.to_unix_ms, time_step_seconds : Int32 = DEFAULT_TIME_STEP_SECONDS)
    number = generate_number(base32_secret, time_millis, time_step_seconds)
    "%06d" % number
  end

  # Return the QR image url thanks to Google. This can be shown to the user and scanned by the authenticator program
  # as an easy way to enter the secret.
  # * key_id: Name of the key that you want to show up in the users authentication application. Should already be URL encoded.
  # * secret: Secret string that will be used when generating the current number.
  def self.qr_code_url(key_id : String, secret : String)
    otp_url = otp_auth_url(key_id, secret)
    "https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl=200x200&chld=M|0&cht=qr&chl=#{otp_url}"
  end

  # Return the otp-auth part of the QR image which is suitable to be injected into other QR generators (e.g. JS generator)
  # * key_id: Name of the key that you want to show up in the users authentication application. Should already be URL encoded.
  # * secret: Secret string that will be used when generating the current number.
  def self.otp_auth_url(key_id : String, secret : String)
    "otpauth://totp/#{key_id}%3Fsecret%3D#{secret}"
  end

  # Generates the base number for the authenticator but has no zero padding
  private def self.generate_number(base32_secret : String, time_millis : Int64, time_step_seconds : Int32) : Int32
    key = Base32.decode_as_bytes(base32_secret)

    data = Bytes.new(8)
    value = time_millis / 1000 / time_step_seconds
    (1..7).to_a.reverse.each { |i| data[i] = (value & 0xFF).to_u8; value >>= 8 }

    # encrypt the data with the key and return the SHA1 of it in hex
    hash_bytes = OpenSSL::HMAC.hexdigest(:sha1, key, data).hexbytes

    # take the 4 least significant bits from the encryped string as an offset
    offset = hash_bytes[hash_bytes.size - 1] & 0xF

    truncated_hash = 0
    i = offset
    while i < offset + 4
      truncated_hash <<= 8
      # get the 4 bytes at the offset
      truncated_hash |= (hash_bytes[i] & 0xFF)
      i += 1
    end

    # cut off the top bit
    truncated_hash &= 0x7FFFFFFF

    # the token is then the last 6 digits in the number
    truncated_hash %= 1000000
    truncated_hash
  end
end
