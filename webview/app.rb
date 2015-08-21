require 'sinatra'
require 'neo4j'
require './models'

set :public_folder, File.dirname(__FILE__) + '/static'

neo4j_url = ENV['NEO4J_URL'] || 'http://localhost:7474'
neo4j_username = ENV['NEO4J_USERNAME']
neo4j_password = ENV['NEO4J_PASSWORD']

Neo4j::Session.open(:server_db, neo4j_url, basic_auth: {username: neo4j_username, password: neo4j_password})

get '/' do
  File.read(File.join(File.dirname(__FILE__), 'static/index.html'))
end

get '/search' do
  movies = Movie.where(title: /.*#{request['q']}.*/i) 
  #movies << Movie.where(germanTitle: /.*#{request['q']}.*/i).to_a
  songs =  Song.where(name: /.*#{request['q']}.*/i).to_a
  bands = Band.where(name: /.*#{request['q']}.*/i).to_a
  albums = Album.where(name: /.*#{request['q']}.*/i).to_a
  actors = Actor.where(name: /.*#{request['q']}.*/i).to_a
    
  map = movies.map {|movie| {movie: movie.attributes} }
  map << songs.map { |song| {song: song.attributes}   }
  map << bands.map { |band| {band: band.attributes}   }
  map << albums.map { |album| {album: album.attributes}}
  map << actors.map { |actor| {actor: actor.attributes}} 
  map.flatten.to_json   #movies.map {|movie| {movie: movie.attributes} }.to_json
end

get '/movie/:title' do
  movies  = Movie.where(title: params['title']).to_a
  actors = movies.first.actors.to_a
  songs  = movies.first.uses.to_a
  bands  = []
  albums = []
  songs.each do |song| 
    albums << song.contained.to_a
  end
  albums = albums.flatten
  albums = albums.uniq
  albums.each do |album|
    bands << album.bands.to_a
  end
  bands.flatten!
  bands.uniq!
  
  map = movies.map {|movie| {movie: movie.attributes.merge({highlight: "true"})} }
  map << songs.map { |song| {song: song.attributes}   }
  map << bands.map { |band| {band: band.attributes}   }
  map << albums.map { |album| {album: album.attributes}}
  map << actors.map { |actor| {actor: actor.attributes.merge(actor.rel.props)}}
  map.flatten.to_json 
end

get '/song/:title' do
  songs  = Song.where(name: params['title']).to_a
  movies  = songs.first.uses.to_a
  albums = songs.first.contained.to_a
  bands  = []
  albums.each do |album|
    bands << album.bands.to_a
  end
  bands.flatten!
  bands.uniq!
  
  map = movies.map {|movie| {movie: movie.attributes} }
  map << songs.map { |song| {song: song.attributes.merge({highlight: "true"})}   }
  map << bands.map { |band| {band: band.attributes}   }
  map << albums.map { |album| {album: album.attributes}}
  map.flatten.to_json 
end

get '/actor/:title' do
  actors = Actor.where(name: params['title']).to_a
  movies  = actors.first.acted_in.to_a
  songs = []
  movies.each do |movie|
    songs << movie.uses.to_a
  end
  songs.flatten!
  bands  = []
  albums = []
  songs.each do |song| 
    albums << song.contained.to_a
  end
  albums = albums.flatten
  albums = albums.uniq
  albums.each do |album|
    bands << album.bands.to_a
  end
  bands.flatten!
  bands.uniq!
  
  map = movies.map {|movie| {movie: movie.attributes} }
  map << songs.map { |song| {song: song.attributes}   }
  map << bands.map { |band| {band: band.attributes}   }
  map << albums.map { |album| {album: album.attributes}}
  map << actors.map { |actor| {actor: actor.attributes.merge({highlight: "true"})}}
  map.flatten.to_json 
end

