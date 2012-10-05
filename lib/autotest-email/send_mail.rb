require 'rubygems'
require 'rmail'
require 'net/smtp'
require 'autotest-email'

module SendMail
  # Default settings. You may change all of them on each call of send_mail method.
  @defaults = {
    :smtp => {
      :address => 'smtp.gmail.com',
      :port => 587,
      :domain => 'gmail.com', # This field sends on HELO request
      :user_name => Autotest::Email.user_name,
      :password => Autotest::Email.password,
      :authentication => :plain # Supported 3 types: :plain, :login, :cram_md5
    },   
    :from => {
      :email => Autotest::Email.from
    },   
    :options => {
      :charset => 'utf-8',
      :priority => 3, # The priority header used in many mail programs. You can see priority hash below
      :quoted_printable => true, # Using quoted-printable transfer encoding in E-Mail. If this field missed
                                 # using default transfer encoding (7bit) - not all servers support it.
      :attachments_transfer_encoding => :base64 # Supported 2 types: :base64, :quoted_printable.
    }
  }
 
  @priorities = {
    2 => 'High',
    3 => 'Normal',
    4 => 'Low'
  }
 
  def self.quoted_printable(text)
    text
  end
 
  def self.send_mail(params)
    params[:smtp] ||= {}
    params[:to] = [params[:to]] if params[:to].class != Array
    params[:from] ||= {}
    params[:options] ||= {}
    params[:attachments] ||= []
    params[:attachments] = [params[:attachments]] if params[:attachments].class != Array
    @options = {}
   
   
    email = RMail::Message.new
   
    @options[:quoted_printable] = params[:options][:quoted_printable].nil? ? @defaults[:options][:quoted_printable] : params[:options][:quoted_printable]
    @options[:charset] = params[:options][:charset].nil? ? @defaults[:options][:charset] : params[:options][:charset]
   
   
    to_list = RMail::Address::List.new
    for to in params[:to]
      to = {:email => to} if to.class != Hash
     
      address_string = to[:name].nil? ? to[:email] : "#{self.quoted_printable(to[:name])} <#{to[:email]}>"
      to_list << RMail::Address.new(address_string)
    end
    email.header.to = to_list

    from_name = params[:from][:name].nil? ? @defaults[:from][:name] : params[:from][:name]
    from_name = self.quoted_printable(from_name)
    from_email = params[:from][:email].nil? ? @defaults[:from][:email] : params[:from][:email]
    email.header.from = from_name.nil? ? from_email : "#{from_name} <#{from_email}>"
   
    if !params[:reply_to].nil?
      params[:reply_to] = {:email => params[:reply_to]} if params[:reply_to].class != Hash
     
      email.header.reply_to  = params[:reply_to][:name].nil? ? params[:reply_to][:email] : "#{self.quoted_printable(params[:reply_to][:name])} <#{params[:reply_to][:email]}>"
    end
   
    email.header.subject = self.quoted_printable(params[:subject])
   
    priority = params[:options][:priority].nil? ? @defaults[:options][:priority] : params[:options][:priority]
    email.header['X-Priority'] = "#{priority} (#{@priorities[priority]})"
   
    main = RMail::Message.new
    main.header['Content-Transfer-Encoding'] = @options[:quoted_printable] ? 'quoted-printable' : '7bit'
    main.header.add 'Content-Type', 'text/plain', nil, 'charset' => @options[:charset]
    main.body = params[:body]
   
    email.add_part(main)
   
   
    for attachment in params[:attachments]
      part = RMail::Message.new
     
      transfer_encoding = attachment[:transfer_encoding].nil? ? params[:options][:attachments_transfer_encoding] : attachment[:transfer_encoding]
      transfer_encoding = @defaults[:options][:attachments_transfer_encoding] if transfer_encoding.nil?
     
      case transfer_encoding
        when :base64
          part.header['Content-Transfer-Encoding'] = 'base64'
          part.body = [attachment[:content]].pack('m')
        when :quoted_printable
          part.header['Content-Transfer-Encoding'] = 'quoted-printable'
          part.body = [attachment[:content]].pack('M*')
      end
     
      part.header.add 'Content-Type', attachment[:mime_type], nil, 'name' => quoted_printable(attachment[:filename])
      part.header.add 'Content-Disposition', 'attachment', nil, 'filename' => quoted_printable(attachment[:filename])
     
      email.add_part(part)
    end
   
   
    server = params[:smtp][:address].nil? ? @defaults[:smtp][:address] : params[:smtp][:address]
    port = params[:smtp][:port].nil? ? @defaults[:smtp][:port] : params[:smtp][:port]
    domain = params[:smtp][:domain].nil? ? @defaults[:smtp][:domain] : params[:smtp][:domain]
    login = params[:smtp][:user_name].nil? ? @defaults[:smtp][:user_name] : params[:smtp][:user_name]
    password = params[:smtp][:password].nil? ? @defaults[:smtp][:password] : params[:smtp][:password]
    authentication = params[:smtp][:authentication].nil? ? @defaults[:smtp][:authentication] : params[:smtp][:authentication]
   
    #email.header['Message-Id'] = "#{MD5.new(Time.now.to_s + 'send_mail_noise').hexdigest}@#{domain}"
    email.header['Message-Id'] = "#{Time.now.to_s}@#{domain}"
    email.header.date = Time.now

    Net::SMTP.start(server, port, domain, login, password, authentication) do |smtp|
      smtp.send_mail RMail::Serialize.write('', email), from_email, email.header.to.addresses
    end
  end
end

