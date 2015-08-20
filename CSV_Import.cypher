CREATE CONSTRAINT ON (b:BAND) ASSERT b.id IS UNIQUE;
CREATE CONSTRAINT ON (a:ALBUM) ASSERT a.id IS UNIQUE;
CREATE CONSTRAINT ON (s:SONG) ASSERT s.id IS UNIQUE;

// Check CSV
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/songs.csv" AS line WITH line
RETURN line
LIMIT 1;


// Import Band
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/band.csv" AS line 
WITH line
MERGE(b:BAND {name:line.name})
SET b.id = TOINT(line.id)

// Import Albums
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/album.csv" AS line 
WITH line
MERGE(a:ALBUM {name:line.name})
SET a.id = TOINT(line.id)
SET a.pubDate = line.pubDate
MERGE(b:BAND {id: TOINT(line.bandId)})
CREATE (a)-[:IS_FROM]->(b)


// IMPORT SONGS
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/songs.csv" AS line 
WITH line
MERGE(s:SONG {name:line.name})
SET s.id = TOINT(line.id)
SET s.pubDate = line.pubDate
MERGE (a:ALBUM {id:TOINT(line.albumId)})
CREATE (a)-[:CONTAINS]->(s)
CREATE (s) -[:IS_FROM]-> (a)

// IMPRT MOVIES
LOAD CSV WITH HEADERS FROM "https://github.com/yremmet/MovieSongsDB/raw/master/movie.csv" AS line 
MERGE(m:MOVIE {title:line.title})
SET m.id = TOINT(line.id)
SET m.germanTitle = line.germanTitle
SET m.year = TOINT(line.year)
MERGE(s:SONG {id:TOINT(line.song)})
CREATE(m) -[:USES]->	(s)
CREATE(s) -[:USED_IN]->(m)