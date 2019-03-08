/* EXAMPLE OF HOW TO START */
LOAD CSV WITH HEADERS FROM 'file:///test.csv' AS line
MERGE (author:Author { name:line.Name})
MERGE (paper:Paper {name: line.Paper})
MERGE (year:Year{year:toInteger(line.Year)})
MERGE (conference:Conference{name:line.Conference})
MERGE (kw:KeyWord{name:line.KeyWord})
MERGE (article:Article{name:line.article})




CREATE
	(author)-[:Write]->(paper),
    (paper)-[:publishedAT]->(year),
    (paper)-[:publishedIN]->(conference),
    (paper)-[:HasKeyWord]->(kw)
;
/*--------------------------------------------*/


/* EXAMPLE OF MIX DATA FROM DIFERENT SOURCES */
LOAD CSV WITH HEADERS FROM 'file:///csv1.csv' AS first
LOAD CSV WITH HEADERS FROM 'file:///csv2.csv' AS second
MERGE (Paper:paper {name: first.paper})
MERGE (Author:author {name:first.author})
MERGE (Key:key {name: second.key})

WITH second, Key
MATCH(Paper_aux:paper)
WHERE Paper_aux.name = second.paper
MERGE (Paper_aux)-[:KEYWORD]->(Key)
;
/*--------------------------------------------*/

LOAD CSV WITH HEADERS FROM 'file:///Journal.csv' AS first
LOAD CSV WITH HEADERS FROM 'file:///Conference.csv' AS second
LOAD CSV WITH HEADERS FROM 'file:///KeyWords.csv' AS first
LOAD CSV WITH HEADERS FROM 'file:///Reviews.csv' AS second
