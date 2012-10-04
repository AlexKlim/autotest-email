require "autotest-email/version"
require 'mail'

module Autotest

  class << self
    attr_accessor: :address, :port, :user_name, :password, :enable_ssl

    def configure
      yield self
    end
  end

  module Email

    def get
      init()
      mail = Mail.first
      p mail.envelope.from 
    end

    private 
    
    def init()
      Mail.defaults do
	retriever_method :pop3, 
	  :address    => AutotestEmail.address,
          :port       => AutotestEmail.port,
          :user_name  => AutotestEmail.user_name,
          :password   => AutotestEmail.password,
          :enable_ssl => AutotestEmail.enable_ssl
      end

    end
  end

AutotestEmail.configure do |config|
  config.address = 'pop.gmail.com'
  config.port = 995
  config.user_name = 'example@gmail.com'
  config.password = 'password'
  config.enable_ssl = true
end

end
