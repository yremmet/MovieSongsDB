CREATE CONSTRAINT ON (b:BAND) ASSERT b.id IS UNIQUE;
CREATE CONSTRAINT ON (a:ALBUM) ASSERT a.id IS UNIQUE;
CREATE CONSTRAINT ON (s:SONG) ASSERT s.id IS UNIQUE;
CREATE CONSTRAINT ON (m:MOVIE) ASSERT m.id IS UNIQUE;

// Check CSV
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/songs.csv" AS line WITH line
RETURN line
LIMIT 1;


// Import Band
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/band.csv" AS line 
WITH line
MERGE(b:Band {name:line.name})
SET b.id = TOINT(line.id);

// Import Albums
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/album.csv" AS line 
WITH line
MERGE(a:Album {name:line.name})
SET a.id = TOINT(line.id)
SET a.pubDate = line.pubDate
MERGE(b:Band {id: TOINT(line.bandId)})
CREATE (a)-[:IS_FROM]->(b);


// IMPORT SONGS
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/songs.csv" AS line 
WITH line
MERGE(s:Song {name:line.name})
SET s.id = TOINT(line.id)
SET s.pubDate = line.pubDate
MERGE (a:Album {id:TOINT(line.albumId)})
CREATE (a)-[:CONTAINS]->(s)
CREATE (s) -[:IS_FROM]-> (a);

// IMPRT MOVIES
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/movie.csv" AS line 
MERGE(m:Movie {title:line.title})
SET m.id = TOINT(line.id)
SET m.germanTitle = line.germanTitle
SET m.year = TOINT(line.year)
MERGE(s:Song {id:TOINT(line.song)})
CREATE (m) -[:USES]->	(s)
CREATE (s) -[:USED_IN]->(m);

// IMPORT ACTORS
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/actor.csv" AS line 
MERGE(ac:Actor {name:line.name})
SET ac.id = TOINT(line.id)
MERGE(m:Movie {id:TOINT(line.movie)})
CREATE (ac) -[:PLAYS {role:line.rolename}]->(m);