require 'zlib'
require 'aws'

module S3Gzip
  class Writer
    attr_reader :bucket
    attr_reader :filename

    def initialize(access_key_id, secret_access_key, bucket, filename)

      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @bucket = bucket
      @filename = filename
      
      s3 = AWS::S3.new(
        :access_key_id => access_key_id,
        :secret_access_key => secret_access_key
      )
      bucket = s3.buckets[bucket]
      s3_object = bucket.objects[filename]
      @io = S3io.open(s3_object, 'w') 
      @gzip_writer = Zlib::GzipWriter.new(@io)
    end

    def closed?
      not @gzip_writer.nil? and @gzip_writer.closed?
    end

    def write(*args)
      @gzip_writer.write(*args)
    end

    def close
      unless self.closed?
        @gzip_writer.close
        @io=nil
      end
    end

    def self.open(*args)
      writer = new(*args)
      return writer unless block_given?
      yield writer
    ensure
      writer.close if block_given?
    end

    def self.write(access_key_id, secret_access_key, bucket, filename, value)
      writer = new(access_key_id, secret_access_key, bucket, filename)
      writer.write(value)
      writer.close
    end
  end
end