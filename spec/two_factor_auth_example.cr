require "../src/crystal-two-factor-auth"

# TOTP.generate_base32_secret
base32_secret = "NY4A5CPJZ46LXZCP"

# this is the name of the key which can be displayed by the authenticator program
key_id = "kings@sushichain.io"

# generate the QR code
# we can display this image to the user to let them load it into their auth program
puts "Image url: #{TOTP.qr_code_url(key_id, base32_secret)}"

# we can use the auth number here and compare it against user input
# auth_number = TOTP.generate_number_string(base32_secret)
# is_valid = TOTP.validate_number_string(base32_secret, auth_number)

# this loop shows how the number changes over time
while true
  diff = TOTP::DEFAULT_TIME_STEP_SECONDS - ((Time.now.epoch_ms / 1000) % TOTP::DEFAULT_TIME_STEP_SECONDS)
  code = TOTP.generate_number_string(base32_secret)
  puts "Secret code = #{code}, change in #{diff} seconds"
  sleep 1
end
