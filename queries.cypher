/* h-indexes DONE*/
MATCH(person:Scientific)-[:writes]->(paper:Scientific_Paper)-[:refersTo]->(citations:Scientific_Paper)
WITH person, paper, count(citations) AS citations_no
ORDER BY person, citations_no DESC
WITH person, collect(citations_no) as citations_list
WITH person,  citations_list, range(0, size(citations_list)-1) AS index
UNWIND index AS i
WITH person, citations_list, index, collect(citations_list[i]-(i+1)) as rest
WITH person, citations_list, [x IN range(0, size(citations_list)-1) WHERE rest[x] < 0 ] AS result
RETURN person, citations_list, CASE WHEN size(result) = 0  THEN size(citations_list) ELSE head(result) END as h-index
ORDER BY h-index DESC

/* returns the conference and its top cited papers DONE*/
MATCH (citing_paper:Scientific_Paper)-[:refersTo]->
(cited_paper:Scientific_Paper)-[:publishedON]->(proceeding:Proceeding)-[:isEdition]->(conference:Conference)
WITH conference, cited_paper, count(citing_paper) as references
ORDER BY references DESC
WITH conference, collect(cited_paper) as cited_papers
RETURN conference, cited_papers[..3]

/*  For each conference, find its community DONE*/
MATCH (person:Scientific)-[:writes]->(paper:Scientific_Paper)-[:publishedON]->(edition:Proceeding)-[:isEdition]->(conference:Conference)
WITH person, collect(edition) as editions, conference
WHERE size(editions) >= 4
RETURN person,conference

/*  Find the impact factors of the journals in the graph DONE*/
MATCH (paper:Scientific_Paper)-[:publishedON]->(edition:Volume)-[:AtYear]->(year:Year)
WHERE year.year = "2019"
WITH collect(paper) as papers_2019
MATCH (paper:Scientific_Paper)-[:publishedON]->(edition:Volume)-[:AtYear]->(year:Year)
WHERE year.year = "2018" OR year.year = "2017"
MATCH (cited_paper:Scientific_Paper)-[:refersTo]->(paper)
WHERE cited_paper IN papers_2019
MATCH (edition)-[:isEdition]->(journal:Journal)
WITH count(cited_paper) as no_citings, paper, journal
RETURN journal, tofloat(sum(no_citings))/tofloat(count(paper))




-----3-----
/* Betweenness Centrality Algorithm scientific_paper->Node, refersTo->Edge*/
CALL algo.betweenness.stream('Scientific','publish',{direction:'out'})
YIELD nodeId, centrality
MATCH (person:Scientific) WHERE id(person) = nodeId
RETURN person.name AS person,centrality
ORDER BY centrality DESC;

/*Page Rank Algorithm*/
CALL algo.pageRank.stream('Scientific_Paper', 'refersTo', {iterations:20, dampingFactor:0.85})
YIELD nodeId, score
RETURN algo.getNodeById(nodeId).name AS paper,score
ORDER BY score DESC



-----3-----
/* Betweenness Centrality Algorithm scientific_paper->Node, refersTo->Edge*/
CALL algo.betweenness.stream('Scientific','publish',{direction:'out'})
YIELD nodeId, centrality
MATCH (person:Scientific) WHERE id(person) = nodeId
RETURN person.name AS person,centrality
ORDER BY centrality DESC;

/*Page Rank Algorithm*/
CALL algo.pageRank.stream('Scientific_Paper', 'refersTo', {iterations:20, dampingFactor:0.85})
YIELD nodeId, score
RETURN algo.getNodeById(nodeId).name AS paper,score
ORDER BY score DESC

/*Single Source Shortest Path--  This should give the shortest path to all nddes from the node in the match statement*/
MATCH (paper:Scientific_Paper {name:'Nonterminals Versus Homomorphisms in Defining Languages for Some Classes of Rewriting Systems.'})
CALL algo.shortestPath.deltaStepping.stream(n)
YIELD nodeId, distance
RETURN algo.getNodeById(nodeId).name AS destination, distance
