# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Pony.mail({
  :to => 'khandennis@gmail.com',
  :via => :smtp,
  :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => 'khandennis',
    :password             => 'Jesus0%Lord',
    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
  }
})
