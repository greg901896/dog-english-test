require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "visiting the login page" do
    visit root_url
    assert_selector "h2", text: "登入"
  end
end
