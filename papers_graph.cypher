/* First of all load load data from CSV */
LOAD CSV WITH HEADERS FROM 'file:///journals_50.csv' AS journals


/* Create all the nodes related with JOURNAL and relations */
MERGE (journal_author:Scientific {name:journals.Author})
MERGE (journal:Journal {name:journals.Journal})
MERGE (journal_year:Year {year:journals.Year})
MERGE (journal_paper:Scientific_Paper {name:journals.Paper})
MERGE (journal_editor:Scientific {name:journals.Editor})
MERGE (journal_city:City {name:journals.City})
MERGE(journal_edition:Journal_edition {name:journals.Edition, year:journals.Year})

MERGE (journal_author)-[:publish]->(journal_paper)
MERGE (journal_paper)-[:publishedON]->(journal)
MERGE (journal_paper)-[:edition]->(journal_edition)
MERGE (journal)-[:city]->(journal_city)
MERGE (journal)-[:edit_by]->(journal_editor)
MERGE (journal)-[:hasEdition]->(journal_edition)

WITH count(*) as dummy

MATCH (year:Year), (edition:Journal_edition)
WHERE year.year = edition.year
MERGE (edition)-[:AtYear]->(year)


WITH count(*) as dummy


/* Create all the nodes_related with CONFERENCE and relations*/
LOAD CSV WITH HEADERS FROM 'file:///conferences_50.csv' AS conferences
MERGE (conference_author:Scientific {name:conferences.Author})
MERGE (conference:Conference {name:conferences.Conference})
MERGE (conference_year:Year {year:conferences.Year})
MERGE (conference_paper:Scientific_Paper {name:conferences.Paper})
MERGE (conference_editor:Scientific {name:conferences.Editor})
MERGE (conference_city:City {name:conferences.City})
MERGE (conference_edition:Conference_edition {name:conferences.Edition, year:conferences.Year})

MERGE (conference_author)-[:publish]->(conference_paper)
MERGE (conference_paper)-[:publishedON]->(conference)
MERGE (conference_paper)-[:edition]->(conference_edition)
MERGE (conference)-[:city]->(conference_city)
MERGE (conference)-[:edits]->(conference_editor)
MERGE (conference)-[:hasEdition]->(conference_edition)

WITH count(*) as dummy

MATCH (year:Year), (edition:Conference_edition)
WHERE year.year = edition.year
MERGE (edition)-[:AtYear]->(year)

WITH count(*) as dummy

/* Create all the nodes realted with keywords */
LOAD CSV WITH HEADERS FROM 'file:///keywords_50.csv' AS keywords
MERGE (keyword:KeyWord {name:keywords.Keyword})
WITH keywords, keyword
MATCH (paper:Scientific_Paper)
WHERE paper.name = keywords.Paper
MERGE (paper)-[:HasKeyWord]->(keyword)

WITH count(*) as dummy

/* Create all nodes related with references */
LOAD CSV WITH HEADERS FROM 'file:///references_50.csv' AS refers
WITH refers
MATCH (paper:Scientific_Paper),(reference:Scientific_Paper)
WHERE paper.name = refers.paper AND reference.name = refers.reference AND paper.name <> reference.name
MERGE (paper)-[:refersTo]->(reference)

WITH count(*) as dummy

/* Create all nodes related with reviews */
LOAD CSV WITH HEADERS FROM 'file:///reviews_50.csv' AS reviews
MATCH (author:Scientific)-[:publish]->(author_paper:Scientific_Paper),(editor:Scientific),(paper_review:Scientific_Paper)
WHERE author.name = reviews.Author AND editor.name = reviews.Editor AND paper_review.name = reviews.Paper AND author_paper.name <> paper_review.name
MERGE (editor)-[:Assigns_paper{name:paper_review.name}]->(author)
;
