
// REMOVE ALL NODES
// MATCH (n) DETACH DELETE n

// QUERY ALL ENDANGERED ANIMALS
// MATCH ((s:Conservation_Status {status: "endangered"})-[:IDENTIFIEDAS]-(a:Animal)) RETURN a

CREATE CONSTRAINT ON (a: Animal) ASSERT a.animal_name IS UNIQUE; 
CREATE CONSTRAINT ON (a: Alias) ASSERT a.alias IS UNIQUE; 
CREATE CONSTRAINT ON (h: Feeding_Habit) ASSERT h.habit IS UNIQUE; 
CREATE CONSTRAINT ON (c: Conservation_Status) ASSERT c.status IS UNIQUE; 
CREATE CONSTRAINT ON (c: Class) ASSERT c.name IS UNIQUE;
CREATE CONSTRAINT ON (o: Order) ASSERT o.name IS UNIQUE;
CREATE CONSTRAINT ON (f: Family) ASSERT f.name IS UNIQUE;
CREATE CONSTRAINT ON (s: Suborder) ASSERT s.name IS UNIQUE;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM 'file:///animals.csv' as line
WITH line,
     SPLIT(line.`Taxonomy`, ';') as taxonomy,
     SPLIT(line.`Also known as`, ',') as aliases,
     SPLIT(line.`Conservation Status`, '/') as conserv_statuses

CREATE (animal:Animal {animal_name: line.`Fish name`, 
                       distribution: line.Distribution,
                       ecosystem: line.`Ecosystem/Habitat`})

MERGE (feed_habit:Feeding_Habit {habit: line.`Feeding Habits`})

FOREACH (al IN CASE WHEN NOT line.`Also known as` CONTAINS 'N/A' 
                    THEN aliases ELSE [] END | MERGE (alia:Alias {alias: al})
                                               CREATE (alia)<-[:KNOWNAS]-(animal))

FOREACH (cs IN CASE WHEN NOT line.`Conservation Status` CONTAINS 'N/A' 
                    THEN conserv_statuses ELSE [] END | MERGE (con_stat:Conservation_Status {status: TOLOWER(cs)})
                                                        CREATE (con_stat)<-[:IDENTIFIEDAS]-(animal))

CREATE (feed_habit)<-[:IDENTICALFEEDINGHABITS]-(animal)