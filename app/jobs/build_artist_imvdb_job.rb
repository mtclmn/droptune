class BuildArtistImvdbJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :artists

  sidekiq_throttle({
    # Allow maximum 10 concurrent jobs of this class at a time.
    :concurrency => { :limit => 10 },
    # Allow maximum 1K jobs being processed within one hour window.
    :threshold => { :limit => 8, :period => 5.seconds }
  })

  def perform(artist_id)
    artist = Artist.find artist_id
    page = 1
    loop do
      response = HTTParty.get('http://imvdb.com/api/v1/search/videos', {
        query: {q: artist.name, per_page: 50, page: page},
        headers: {"IMVDB-APP-KEY" => ENV['imvdb_key']}
      })
      break if response.parsed_response.blank? or response.parsed_response['results'].blank?

      response.parsed_response['results'].each do |vid|
        vid_artist_name = vid['artists'].first['name']

        if vid_artist_name.to_s.downcase == artist.name.to_s.downcase
          vid_id = vid['id']

          response = HTTParty.get("https://imvdb.com/api/v1/video/#{vid_id}?include=sources", {headers: {"IMVDB-APP-KEY" => ENV['imvdb_key']}})
          video = response.parsed_response
          source = video['sources'].first

          if source.present? and video['image'].present?
            source_data = source['source_data'].to_s

            if video['release_date_string'].blank? and video['year'].present?
              release_date = Date.strptime("#{video['year']}-01-01", '%Y-%m-%d')
            elsif video['release_date_string'].present?
              release_date = Date.parse(video['release_date_string'])
            else
              release_date = Date.today-1.year
            end

            music_video = MusicVideo.where('artist_id = ? AND source_data = ?', artist.id, source_data).first_or_create(
                artist_id: artist.id, 
                name: video['song_title'],
                release_date: release_date,
                image: video['image']['o'],
                source: source['source'],
                source_data: source_data)
          end
        end
      end
      page += 1
    end
  end
end