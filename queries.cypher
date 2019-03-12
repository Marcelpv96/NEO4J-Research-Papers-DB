/* h-indexes -- NOT FINISHED*/
MATCH (person:Scientific)-[:publish]->(cited_paper:Scientific_Paper)<-[:refersTo]-(citing_paper:Scientific_Paper)
WITH person,cited_paper, count(citing_paper) as no_of_cites
ORDER BY person, refersTo
WITH person ,collect(no_of_cites) as cite_list
FOREACH ( cite IN cite_list SET n.marked = TRUE)
RETURN person, size(filter(i in IN range(0, size(cite_list)) WHERE i < cite_list[i]))


/* returns the conference and its top cited papers*/
MATCH (citing_paper:Scientific_Paper)-[:refersTo]->(cited_paper:Scientific_Paper)-[:publishedON]->(:volume)-[:of]->(conference:Conference)
WITH conference, cited_paper, count(citing_paper) as references
ORDER BY references DESC
LIMIT 3
RETURN conference, cited_paper /* references[0..2] ?? */

/*  For each conference, find its community NOT FINISHED*/
MATCH (person:Scientific)->[:publishes]->(paper:Scientific_Paper)->[:publishedON]->()->[]->(conference:Conference)
WHERE (n2:Scientific_Paper)->[e2:publishedIN]->()
RETURN n3,n1


MATCH (paper:Scientific_Paper {name:'nnnnn'})
CALL algo.shortestPath.deltaStepping.stream(n)
YIELD nodeId, distance
RETURN algo.getNodeById(nodeId).name AS destination, distance