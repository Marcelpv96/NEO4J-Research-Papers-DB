/* 1- Data base community contains the following kw :data management, indexing, data modeling, big data, data
processing, data storage and data querying.*/

/* 2- Obtain papers that are related to db comunity */

MATCH (kw:KeyWord)<-[:HasKeyWord]-(journal_paper:Scientific_Paper)
MATCH (journal_paper:Scientific_Paper)-[:publishedON]->(edition:Journal_edition)
WHERE kw.name = "data management" OR kw.name  = "indexing" OR kw.name = "data modeling" OR kw.name = "big data" OR kw.name = "data processing" or kw.name = "data storage" OR kw.name = "data.querying"
return edition
