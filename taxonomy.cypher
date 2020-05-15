////////////////

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM 'file:///animals.csv' as line
WITH line,
     SPLIT(line.Taxonomy, CASE WHEN line.Taxonomy CONTAINS ';' 
                               THEN ';' 
                               WHEN line.Taxonomy CONTAINS '),' 
                               THEN '),' 
                               ELSE ',' END) as taxonomy

MATCH (animal:Animal {animal_name: line.`Fish name`})

FOREACH (_ IN CASE WHEN TOLOWER(line.Taxonomy) CONTAINS "family" AND 
                        TOLOWER(line.Taxonomy) CONTAINS "order"
                        THEN [1] ELSE [] END | MERGE (o:Order {name: REPLACE(TOLOWER(taxonomy[0]), 'order ', '')})
                                               MERGE (f:Family {name: REPLACE(TOLOWER(taxonomy[1]), 'family ', '')})
                                               CREATE (o)<-[:BELONGSTO]-(f)
                                               CREATE (f)<-[:PARTOF]-(animal))

FOREACH (_ IN CASE WHEN TOLOWER(line.Taxonomy) CONTAINS "class" AND 
                        TOLOWER(line.Taxonomy) CONTAINS "order"
                        THEN [1] ELSE [] END | MERGE (c:Class {name: REPLACE(TOLOWER(taxonomy[0]), 'class ', '') })
                                               MERGE (o:Order {name: REPLACE(TOLOWER(taxonomy[1]), 'order ', '') })   
                                               CREATE (c)<-[:TYPEOF]-(o)
                                               CREATE (o)<-[:PARTOF]-(animal))

FOREACH (_ IN CASE WHEN TOLOWER(line.Taxonomy) CONTAINS "suborder" AND 
                        TOLOWER(line.Taxonomy) CONTAINS "family"
                        THEN [1] ELSE [] END | MERGE (o:Suborder {name: REPLACE(TOLOWER(taxonomy[0]), 'suborder ', '') })   
                                               MERGE (f:Family {name: REPLACE(TOLOWER(taxonomy[1]), 'family ', '')})
                                               CREATE (o)<-[:SUBTYPEOF]-(f)
                                               CREATE (f)<-[:PARTOF]-(animal))