/* 1- Data base community contains the following kw :data management, indexing, data modeling, big data, data
processing, data storage and data querying.*/

/* 2- Obtain papers that are related to db comunity */

/* 1st step, create the DB community*/
MERGE(DBcommunity:Community{Community_name:"DB community"})
WITH DBcommunity
MATCH (kw:KeyWord)
WHERE kw.name = "data management" OR kw.name  = "indexing" OR kw.name = "data modeling" OR kw.name = "big data" OR kw.name = "data processing" or kw.name = "data storage" OR kw.name = "data querying"
MERGE (DBcommunity)-[:HasKeyWord]->(kw)

/* 2nd relate the corresponding journal with each community. */
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
optional match(c:Community{Community_name:"DB community"})<-[:relatedTo]-(journal_edition:Journal_edition)<-[:publishedON]-(journal_papers)<-[:refersTo]-(ref_joun_paper)
return journal_papers as Papers, COUNT(distinct ref_joun_paper) as num_citations
Order by num_citations desc
UNION
optional match (c:Community{Community_name:"DB community"})<-[:relatedTo]-(conference_edition:Conference_edition)<-[:publishedON]-(conference_papers)<-[:refersTo]-(ref_conf_paper)
return conference_papers as Papers, count(distinct ref_conf_paper) as num_citations
ORDER BY num_citations desc
