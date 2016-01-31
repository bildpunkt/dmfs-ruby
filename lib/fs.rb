require 'json'
require 'base64'
require 'base65536'

module DMFS
  def self.create_message(filename)
    # Step 1: Read file and convert it to Base64
    b64 = ""
    File.open filename, 'rb' do |f|
      b64 = Base64.encode64(f.read).gsub("\n", '')
    end

    # Step 1.5 Convert Base64 to Base65536
    # because Base65536 can't handle files
    b65536 = Base65536.encode(b64.bytes)

    # Step 2: Calculate maximum length of Base64 string
    rl = 10000 - (File.basename(filename).length + 31)

    # Step 3: Check length of Base64 string and split if necessary
    b65536s = b65536.scan(/.{1,#{rl}}/)

    # Step 4: Create messages
    messages = []
    b65536sc = 0

    if b65536s.count == 1
      b65536sc = 0
    else
      b65536sc = b65536s.count - 1
    end

    b65536s.each do |string|
      messages << "!!DMFS" + {'fn' => File.basename(filename),
                              'pt' => b65536sc,
                              'ct' => string
      }.to_json
      b65536sc -= 1
    end

    return messages
  end

  $file_parts = Hash.new do |hash, key| hash[key] = {} end

  def self.receive_file_part(dm_id)
    dm = $client.direct_message dm_id, full_text: true
    json = JSON.parse dm.text.sub(/^!!DMFS/, '')
    $file_parts[json['fn']][json['pt']] = json['ct']
    puts "Received part #{json['pt']} of #{json['fn']}"
    save_file(json['fn']) if json['pt'] == 0
  end

  def self.save_file(file_name)
    parts = $file_parts[file_name]
    bae64 = parts.sort{|a, b| a[0] <=> b[0]}.map{|x| x[1]} * ''
    File.open "#{$config['folders']['download']}/#{file_name}", 'wb' do |f|
      f.write Base65536.decode(Base64.decode64(bae64))
    end
    file_name
  end
end
