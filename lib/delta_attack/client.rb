
require 'net/http'
require 'delta_attack/filetype_assumption'
require 'securerandom'

module DeltaAttack
  class Client
    class << self
      def cast(file, content_type = nil, host="localhost", port=3333)
        begin
          client = new(file)
          client.content_type = content_type
          res = Net::HTTP.start(host, port){|http| http.request(client.request) }
          raise "Request failed #{res}" unless res.is_a? Net::HTTPOK
          res.body
        rescue Errno::ECONNREFUSED => e
          raise "DeltaAttack Server is down on http://#{host}:#{port}"
        end
      end
      alias extract cast
    end

    attr_writer :content_type

    def initialize(filename, content=nil)
      @filename = filename
      @content = content
    end

    def boundary
      @boundary ||= SecureRandom.hex(8)
    end

    def content
      @content ||= File.open(@filename,"rb"){|f| f.read }
    end

    def content_type
      @content_type ||= FiletypeAssumption.new(File.basename(@filename)).content_type
    end

    def body
      data = ''
      data << "--#{boundary}\r\n"
      data << "Content-Disposition: form-data; name=\"file\"; filename=\"#{@filename}\"\r\n"
      data << "Content-Type: #{content_type}\r\n\r\n"
      data << content
      data << "\r\n--#{boundary}--\r\n"
    end

    def request(path = "/extract" )
      req = Net::HTTP::Post.new(path)
      req.content_type = "multipart/form-data; boundary=#{boundary}"
      req.body = body
      req.content_length = req.body.size
      req
    end
  end
end

