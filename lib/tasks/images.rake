# ... edited by app gen (DB seeder, Rake tasks, etc...)

require 'open-uri'

namespace :IMAGES do
  PIXABAY = ENV.fetch('PIXABAY').freeze
  DOMAIN = 'pixabay.com'.freeze
  DOMAIN_RE = Regexp.new(Regexp.escape(DOMAIN))

  desc 'Get images'
  task get: :environment do
    # https://pixabay.com/en/photos/?image_type=photo&cat=&min_width=&min_height=&colors=transparent&q=gear&order=latest

    # Good search terms for Pixabay
    [
      'electronics',
      'camera !uav !man',
      'gears',
      'furniture'
    ].each do |search_term|
      ENV['search'] = search_term
      Rake::Task['IMAGES:actual_get'].execute
      sleep 1
    end
  end

  def next_prod(counter)
    prod = Product.all[counter]
    return nil if prod.nil?
    if prod.media !~ DOMAIN_RE
      return Struct.new(:data, :counter).new(prod, counter)
    end

    puts "* Media OK for #{prod.name} #{prod.media} ..."

    sleep 0.25
    next_prod counter + 1
  end

  desc 'Get images'
  task actual_get: :environment do
    search_term = ENV['search']

    query = {
      image_type: 'photo',
      colors: 'transparent'
    }

    query[:q] = search_term if search_term && !search_term.blank?

    uri = URI::HTTPS.build(
      host: DOMAIN,
      path: '/en/photos',
      query: query.to_query
    )

    doc = Nokogiri::HTML open uri.to_s

    photo_grid = doc.css('#photo_grid')

    raise '!= 1 matches for #photo_grid' if photo_grid.count != 1

    counter = 0

    puts "MAIN URL: #{uri}"

    photo_grid.first.css('img').each do |img|
      srcset = img['srcset']
      raise 'srcset is blank' if srcset.blank?

      smallest = srcset.split(/\s* , \s*/x).first
      url = smallest.split(/\s+/).first

      # puts "URL: #{url}"

      prod = next_prod counter

      if !prod
        puts 'All products have images, exiting...'
        exit
      end

      counter = prod.counter
      data = prod.data

      print "Product: #{data.name}... "

      puts 'updating media to...'
      puts "\t" + url
      data.update(media: url)
      counter += 1
    end
  end
end
