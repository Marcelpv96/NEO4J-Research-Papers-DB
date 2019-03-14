/* 1- Data base community contains the following kw :data management, indexing, data modeling, big data, data
processing, data storage and data querying.*/

/* 2- Obtain papers that are related to db comunity */

/* 1st step, create the DB community*/
MERGE(DBcommunity:Community{Community_name:"DB community"})
WITH DBcommunity
MATCH (kw:KeyWord)
WHERE kw.name = "data management" OR kw.name  = "indexing" OR kw.name = "data modeling" OR kw.name = "big data" OR kw.name = "data processing" or kw.name = "data storage" OR kw.name = "data querying"
MERGE (DBcommunity)-[:HasKeyWord]->(kw)

/* 2nd relate the corresponding edition with each community. */
MATCH (all_papers:Scientific_Paper)-[:publishedON]->(edition:Journal_edition)
MATCH (kw:KeyWord)<-[:HasKeyWord]-(kw_paper:Scientific_Paper)-[:publishedON]->(edition:Journal_edition)
WHERE kw.name = "data management" OR kw.name  = "indexing" OR kw.name = "data modeling" OR kw.name = "big data" OR kw.name = "data processing" or kw.name = "data storage" OR kw.name = "data.querying"
WITH edition, COUNT(distinct all_papers) as all_number, COUNT(distinct kw_paper) as kw_papers_number
MATCH (community:Community)
WHERE tofloat(kw_papers_number)/tofloat(all_number) >= 0.9 AND community.Community_name = "DB community"
MERGE (edition)-[:relatedTo]->(community)

WITH count(*) as dummy

MATCH (all_papers:Scientific_Paper)-[:publishedON]->(edition:Conference_edition)
MATCH (kw:KeyWord)<-[:HasKeyWord]-(kw_paper:Scientific_Paper)-[:publishedON]->(edition:Conference_edition)
WHERE kw.name = "data management" OR kw.name  = "indexing" OR kw.name = "data modeling" OR kw.name = "big data" OR kw.name = "data processing" or kw.name = "data storage" OR kw.name = "data.querying"
WITH edition, COUNT(distinct all_papers) as all_number, COUNT(distinct kw_paper) as kw_papers_number
MATCH (community:Community)
WHERE tofloat(kw_papers_number)/tofloat(all_number) >= 0.9 AND community.Community_name = "DB community"
MERGE (edition)-[:relatedTo]->(community)


/*3rd Find the most cited papers in each community*/
CALL algo.pageRank.stream(
    'MATCH (c:Community{Community_name:"DB community"})<-[:relatedTo]-(type)<-[:publishedON]-(citing_paper)
	WITH citing_paper as citer
	MATCH (c:Community{Community_name:"DB community"})<-[:relatedTo]-(type)<-[:publishedON]-(paper)<-[relation:refersTo]-(citer)
	WHERE citer MATCH 
	RETURN distinct paper',
    'refersTo', {iterations:20, dampingFactor:0.85})
YIELD nodeId, score
MATCH (p:Scientific_Paper)
WHERE id(p) = nodeId
WITH p, score LIMIT 100
MATCH (c:Community{Community_name:"DB community"})
MERGE (p)-[:inTop100]->(c)
RETURN p.name, score
ORDER by score DESC

/*4*/
MATCH (person:Scientific)-[:writes]->(paper)-[:inTop100]->(c:Community{Community_name:"DB community"})
WITH person, c, count(paper) as papers
MERGE (person)-[:goodReviewer]->(c)
WITH person, c, papers
WHERE papers >= 2
MERGE (person)-[:isGuru]->(c)