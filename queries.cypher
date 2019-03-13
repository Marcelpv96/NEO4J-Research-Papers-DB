/* h-indexes -- NOT FINISHED*/
MATCH(person:Scientific)-[:publish]->(paper:Scientific_Paper)<-[:refersTo]-(citing_paper:Scientific_Paper)
WITH person, paper, count(citing_paper) as no_cites
ORDER BY person, paper, no_cites
WITH person, collect(no_cites) as cites
WITH person, [i in range(0, size(cites) -1) i+1 <= cites[i]] as cites_flag
RETURN a, size(filter(b in cites_flag WHERE b))

/* returns the conference and its top cited papers DONE*/
MATCH (citing_paper:Scientific_Paper)-[:refersTo]->
(cited_paper:Scientific_Paper)-[:publishedON]->(conference:Conference)
WITH conference, cited_paper, count(citing_paper) as references
ORDER BY references DESC
WITH conference, collect(cited_paper) as cited_papers
RETURN conference, cited_papers[..3]


/*  For each conference, find its community MIGHT BE DONE*/
MATCH (person:Scientific)-[:publishes]->(paper:Scientific_Paper)-[:edition]->(edition:Conference_edition)<-[:hasEdition]-(conference:Conference)
WITH person, collect(edition) as editions, conference
WHERE size(editions) >= 4
RETURN person,conference

/*  Find the impact factors of the journals in the graph MIGHT BE DONE*/
MATCH (paper:Scientific_Paper)-[:edition]->(edition:Journal_edition)-[:AtYear]->(year:Year)
WHERE year.year = "2019"
WITH collect(paper) as papers_2019
MATCH (paper:Scientific_Paper)-[:edition]->(edition:Journal_edition)-[:AtYear]->(year:Year)
WHERE year.year = "2018" OR year.year = "2017"
MATCH (cited_paper:Scientific_Paper)-[:refersTo]->(paper)
WHERE cited_paper IN papers_2019
MATCH (journal:Journal)-[:hasEdition]->(edition)
WITH count(cited_paper) as no_citings, paper, journal
RETURN journal, sum(no_citings)/count(paper)



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
