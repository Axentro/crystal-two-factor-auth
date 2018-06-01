require "./spec_helper"

describe TOTP do
  secret = "NY4A5CPJZ46LXZCP"
  describe "#generate_number_string" do
    it "should generate a valid auth code for known secret time codes" do
      assert_generated_string(secret, 1000_i64, "748810")
      assert_generated_string(secret, 7451000_i64, "325893")
      assert_generated_string(secret, 15451000_i64, "064088")
      assert_generated_string(secret, 348402049542546145_i64, "009637")
      assert_generated_string(secret, 2049455124374752571_i64, "000743")
      assert_generated_string(secret, 1359002349304873750_i64, "000092")
      assert_generated_string(secret, 6344447817348357059_i64, "000007")
      assert_generated_string(secret, 2125701285964551130_i64, "000000")
    end
  end
  describe "#validate_number_string" do
    it "should validate an auth code for known secret time codes" do
      assert_validate_string(true, secret, "325893")
      assert_validate_string(false, secret, "948323")
      assert_validate_string(true, secret, "325893", 15000)
    end
    it "should validate an auth code for known secret time codes for upper window (starts +15000 milliseconds)" do
      assert_validate_string(true, secret, "948323", 15000)
      assert_validate_string(false, secret, "948323", 14999)
    end
    it "should validate an auth code for known secret time codes for lower window (starts -15000 milliseconds - so window of 15001)" do
      assert_validate_string(true, secret, "162123", 15001)
      assert_validate_string(false, secret, "287511", 15000)
    end
    it "should return false if secret and/or auth code is empty" do
      assert_validate_string(false, "", "162123")
      assert_validate_string(false, secret, "")
    end
  end
  describe "#generate_base32_secret" do
    it "should generate a base32 secret key" do
      TOTP.generate_base32_secret.size.should eq(16)
    end
  end
end

def assert_generated_string(secret : String, time_millis : Int64, expected_number : String)
  expected_number.should eq(TOTP.generate_number_string(secret, time_millis))
end

def assert_validate_string(expected : Bool, secret : String, auth_number : String, window_millis : Int32 = 0, time_millis = 7455000_i64)
  TOTP.validate_number_string(secret, auth_number, window_millis, time_millis).should eq(expected)
end
