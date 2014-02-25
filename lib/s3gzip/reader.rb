require 'zlib'
require 'aws'
require 's3io'

module S3Gzip
  class Reader
    def self.read(access_key_id, secret_access_key, bucket, filename)
      s3 = AWS::S3.new(
        :access_key_id => access_key_id,
        :secret_access_key => secret_access_key
      )
      bucket = s3.buckets[bucket]
      s3_object = bucket.objects[filename]
      io = S3io.open(s3_object, 'r')
      result = Zlib::GzipReader.new(io).read
      io.close
      result
    end
  end
end