# Autotest::Email

Gem for support emails for autotests. Get and find email by subject. Send crash report. Clear emails by subject

## Installation

Add this line to your application's Gemfile:

    gem 'autotest-email', git: 'https://github.com/AlexKlim/autotest-email.git'

And then execute:

    $ bundle

## Usage for Cucumber

Add follow lines to a env.rb file:

        require 'autotest-email'
	Include Autotest::Email

	Autotest::Email.configure do |config|
	  #for get email
	  config.address    = 'pop.gmail.com'
	  config.port	    = 995
	  config.user_name  = '<user_email>'
	  config.password   = '<email_apssword>'
	  config.enable_ssl = true

	  #for send email
	  config.to	    = '<email_to_send>' # or you can add list of emails [{:email => 'email1@ex.com'}, {:email => 'email2@ex.com'}]
	  config.reply_to   = 'noreplay@example.com'
	  config.subject    = '<email_subject>'
	  config.body	    = '<email_body>'
	  config.file_name  = '<attach_file_name>' # if needed
	  config.file_path  = '<attach_file_path>' # if needed
	end

We have find_email_by_subject, clear_email_by_subject, send_exception_email

### Use find_email_by_subject method

    find_email_by_subject(to: '<email_who_wait>', subject: '<subject_for_email>')

The method will return body from email.

### User clear_email_by_subject method

    clear_email_by_subject('<subject>')

Just remove all emails with the subject

### User send_exception_email method

    send_exception_email(
      to: <email_or_emailList>, 
      subject: '<can_change_default_subject>',
      body: '<can_change_default_body>',
      file_name: '<file_name_to_attach_file>',
      file_path: '<file_path_to_attach_file>'
    )

Just send crash report.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
