require "autotest-email/version"
require 'mail'

module Autotest

  module Email

    class << self

      attr_accessor :address, :port, :user_name, :password, :enable_ssl
    
      def configure
	yield self
      end
    end

    def find_email_by_subject(option={})
      init()
      body = nil
      while body == nil or time < 15 do
	time += 1

	Mail.all.each do |mail|
	  if mail.to == option[:to] and mail.subject == option[:subject]
	    body = mail.body
	  else
	    body = nil
	  end
	end

	sleep 30
      end
      
      body
    end

    private 
    
    def init()
      Mail.defaults do
	retriever_method :pop3, 
	  :address    => Email.address,
          :port       => Email.port,
          :user_name  => Email.user_name,
          :password   => Email.password,
          :enable_ssl => Email.enable_ssl
      end
    end

  end
end

Autotest::Email.configure do |config|
  config.address = 'pop.gmail.com'
  config.port = 995
  config.user_name = 'example@gmail.com'
  config.password = 'password'
  config.enable_ssl = true
end
