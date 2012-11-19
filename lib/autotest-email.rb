require 'autotest-email/version'
require 'rmail'
require 'net/imap'
require 'net/smtp'

module Autotest

  module Email

    class << self

      attr_accessor :address, :port, :user_name, :password, :enable_ssl
      attr_accessor :from, :to, :subject, :body, :file_name, :file_path, :reply_to
    
      def configure
	yield self
      end
    end

    def find_email_by_subject(option={})
      res = nil
      time = 0

      while res == nil and time < 15 do
        time += 1

        imap = connect
        imap.search(['SUBJECT', option[:subject]]).each do |message_id|
          envelope = imap.fetch(message_id, 'ENVELOPE')[0].attr['ENVELOPE']
          p envelope
          if "#{envelope.to[0].mailbox}@#{envelope.to[0].host}" == option[:to]
            res = message_id
            break
          end
        end
        if res == nil
          imap.disconnect
          sleep 15
        end
      end
      
      msg = imap.fetch(res, '(UID RFC822.SIZE ENVELOPE BODY[TEXT])')[0]
      body = msg.attr['BODY[TEXT]']
      imap.store(res, '+FLAGS', [:Deleted])

      disconnect(imap)

      return body
    end

    def clear_email_by_subject(subject)
      imap = connect
      imap.search(['SUBJECT', subject]).each do |msg|
        imap.store(msg, '+FLAGS', [:Deleted])
      end 
      disconnect(imap)
    end

    def send_exception_email(options={})
      file_path = options[:file_path].nil? ? Email.file_path : options[:file_path]

      SendMail::send_mail(
	:to => options[:to].nil? ? Email.to : options[:to],
	:subject => options[:subject].nil? ? Email.subject : options[:subject],
	:reply_to => options[:reply_to].nil? ? Email.reply_to : options[:replay_to],
	:body => options[:body].nil? ? Email.body : options[:body],
	:options => {
	  :priority => 2,
	  :attachments_transfer_encoding => :quoted_printable
	},
	:attachments => [
	  { 
	    :filename => options[:file_name].nil? ? Email.file_name : options[:file_name],
	    :mime_type => 'image/png',
	    :content => File.open(file_path) {|file| file.sysread(File.size(file))},
	    :transfer_encoding => :base64
	  }
	]
      )
  
    end

    private 
    
    def connect
      imap = Net::IMAP.new(Email.address, Email.port, Email.enable_ssl)
      imap.login(Email.user_name, Email.password)
      imap.select('INBOX')
      imap
    end

    def disconnect(imap)
      imap.expunge
      imap.disconnect
    end

  end

  autoload :SendMail,  'autotest-email/send_mail'

end

Autotest::Email.configure do |config|
  #for get email
  config.address    = 'pop.gmail.com'
  config.port	    = 995
  config.user_name  = 'example@gmail.com'
  config.password   = 'password'
  config.enable_ssl = true

  #for send email
  config.from	    = 'example@gmail.com'
  config.to	    = 'example@gmail.com'
  config.reply_to   = 'noreplay@example.com'
  config.subject    = nil
  config.body	    = nil
  config.file_name  = nil
  config.file_path  = nil
end
