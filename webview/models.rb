class ISIN
  include Neo4j::ActiveRel
  property :roles  # this contains an array of roles
  from_class 'Song'
  to_class 'Album'
  type :IS_IN
end

class CONTAINS
  include Neo4j::ActiveRel
  property :roles  # this contains an array of roles
  from_class 'Album'
  to_class 'Song'
  type :CONTAINS
end

class PLAYS
  include Neo4j::ActiveRel
  property :roles  # this contains an array of roles
  from_class 'Actor'
  to_class 'Movie'
  type :PLAYS
end

class USES
  include Neo4j::ActiveRel
  from_class 'Movie'
  to_class 'Song'
  type :USES
end

class USED
  include Neo4j::ActiveRel
  from_class 'Song'
  to_class 'Movie'
  type :USED
end

class Actor
  include Neo4j::ActiveNode
  property :name
  property :birthday
  has_many :out, :acted_in, model_class: :Movie, rel_class: 'PLAYS'
end

class Movie
  include Neo4j::ActiveNode
  property :title
  property :germanTitle
  property :year
  has_many :in, :actors, model_class: :Actor, rel_class: 'PLAYS'
  has_many :in, :used, model_class: :Song, rel_class: 'USED'
  has_many :out, :uses, model_class: :Song, rel_class: 'USES'
end

class Song
  include Neo4j::ActiveNode
  property :name
  property :pubDate
  has_many :in, :uses, model_class: :Movie, rel_class: 'USES'
  has_many :out, :used, model_class: :Movie, rel_class: 'USED'
  has_many :out, :is_in, model_class: :Album, rel_class: 'ISIN'
  has_many :in, :contained, model_class: :Album, rel_class: 'CONTAINS'
end

class Album
  include Neo4j::ActiveNode
  property :name
  property :pubDate
  has_many :in, :collection, model_class: :Song, rel_class: 'ISIN'
  has_many :out, :songs, model_class: :Song, rel_class: 'CONTAINS'
  has_many :out, :bands, model_class: :Band, type: :IS_FROM
end

class Band
  include Neo4j::ActiveNode
  property :name
  has_many :in, :albums, model_class: :Album, type: :IS_FROM
  
end  
