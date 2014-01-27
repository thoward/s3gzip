require 'zlib'
require 'aws/s3'

module S3Gzip
  class Reader
    def self.read(access_key_id, secret_access_key, bucket, filename)
      AWS::S3::Base.establish_connection!(
        :access_key_id     => access_key_id,
        :secret_access_key => secret_access_key
      )
      Zlib::GzipReader.new(StringIO.new(AWS::S3::S3Object.value(filename, bucket))).read
    end
  end
end