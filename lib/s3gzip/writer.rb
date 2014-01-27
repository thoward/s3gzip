require 'zlib'
require 'aws/s3'

module S3Gzip
  class Writer
    attr_reader :bucket
    attr_reader :filename

    def initialize(access_key_id, secret_access_key, bucket, filename)

      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @bucket = bucket
      @filename = filename

      AWS::S3::Base.establish_connection!(
        :access_key_id     => @access_key_id,
        :secret_access_key => @secret_access_key
      )

      @io = StringIO.new()
      @gzip_writer = Zlib::GzipWriter.new(@io)
    end

    def closed?
      not @gzip_writer.nil? and @gzip_writer.closed?
    end

    def write(*args)
      @gzip_writer.write(*args)
    end

    def close_and_send
      unless self.closed?
        @gzip_writer.close
        AWS::S3::S3Object.store(@filename, @io.string, @bucket)
      end
    end

    def self.open(*args)
      writer = new(*args)
      return writer unless block_given?
      yield writer
    ensure
      writer.close_and_send if block_given?
    end

    def self.write(access_key_id, secret_access_key, bucket, filename, value)
      writer = new(access_key_id, secret_access_key, bucket, filename)
      writer.write(value)
      writer.close_and_send
    end
  end
end