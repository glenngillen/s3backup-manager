module S3BackupManager
  class FileBackup
    attr_accessor :bucket
  
    def initialize(opts = {})
      @bucket = Bucket.find(opts[:bucket])
      super()
    end
  
    def files
      bucket.files.select{|f| f.key.match(%r{^filesystem/})}
    end
  
    def backup(file, directory = "filesystem")
      stored_file_name = "#{Time.now.strftime("%Y%m%d%H%M%S")}/#{File.basename(file)}"
      encrypted_file = encrypt(pack(file))
      bucket.store("#{directory}/#{stored_file_name}", open(encrypted_file))    
      cleanup!
    end
  
    def restore(file, timestamp, destination, directory = "filesystem")
      data = bucket.retrieve("#{directory}/#{timestamp}/#{file}")
      decrypted_file = decrypt(file, timestamp, data)
      unpack(decrypted_file, destination)
      cleanup!
    end
  
    private
      def cleanup!
        if @encrypted_filename
          File.delete(@encrypted_filename) 
          @encrypted_filename = nil
        end
        if @packed_filename
          File.delete(@packed_filename)
          @packed_filename = nil
        end
        if @decrypted_filename
          File.delete(@decrypted_filename) 
          @decrypted_filename = nil
        end
      end
    
      def encrypt(file)
        aes = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
        aes.encrypt
        aes.key = Digest::SHA256.digest(FileBackup.config["encryption_secret"])
        aes.iv = Digest::SHA256.digest(Time.now.strftime("%Y%m%d"))
      
        @encrypted_filename = "#{random_string}_#{File.basename(file)}"
        File.open(@encrypted_filename, 'w') do |enc|
           File.open(file) do |f|
             loop do
               r = f.read(4096)
               break unless r
               cipher = aes.update(r)
               enc << cipher
             end
           end
           enc << aes.final
        end
        @encrypted_filename
      end
      
      def decrypt(filename, timestamp, data)
        aes = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
        aes.decrypt
        aes.key = Digest::SHA256.digest(FileBackup.config["encryption_secret"])
        aes.iv = Digest::SHA256.digest(timestamp[0...8])
        @decrypted_filename = "#{random_string}_#{File.basename(filename)}"
        File.open(@decrypted_filename, 'w') do |dec|
          dec.write aes.update(data)
          dec.write aes.final
        end
        @decrypted_filename
      end
    
      def pack(file)
        @packed_filename = "#{random_string}_#{File.basename(file)}.tgz"
        tgz = Zlib::GzipWriter.new(File.open(@packed_filename, 'wb'))
        Archive::Tar::Minitar.pack("#{file}", tgz, recurse_directories = true)
        @packed_filename
      end
      
      def unpack(file, destination)
        tgz = Zlib::GzipReader.new(File.open(file, 'rb'))
        Archive::Tar::Minitar.unpack(tgz, destination)
      end
    
      def random_string
        o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
        (0..50).map{ o[rand(o.length)]  }.join
      end
    
      def self.config
        YAML.load_file("#{File.dirname(__FILE__)}/../config/config.yml")
      end
  end
end