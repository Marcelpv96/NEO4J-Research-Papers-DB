/* First of all load load data from CSV */
LOAD CSV WITH HEADERS FROM 'file:///journals_10.csv' AS journals


/* Create all the nodes related with JOURNAL and relations */
MERGE (journal_author:Scientific {name:journals.Author})
MERGE (journal:Journal {name:journals.Journal})
MERGE (journal_year:Year {year:journals.Year})
MERGE (journal_paper:Scientific_Paper {name:journals.Paper})
MERGE (journal_editor:Scientific {name:journals.Editor})
MERGE (journal_city:City {name:journals.City})
MERGE(journal_editon:Journal_edition {name:journals.Edition})


MERGE (journal_author)-[:publish]->(journal_paper)
MERGE (journal_paper)-[:publishedON]->(journal)
MERGE (journal_paper)-[:edition]->(journal_editon)
MERGE (journal_edition)-[:AtYear]->(journal_year)
MERGE (journal)-[:city]->(journal_city)
MERGE (journal)-[:edit_by]->(journal_editor)
;

LOAD CSV WITH HEADERS FROM 'file:///conferences_10.csv' AS conferences
/* Create all the nodes_related with CONFERENCE and relations*/
MERGE (conference_author:Scientific {name:conferences.Author})
MERGE (conference:Conference {name:conferences.Conference})
MERGE (conference_year:Year {year:conferences.Year})
MERGE (conference_paper:Scientific_Paper {name:conferences.Paper})
MERGE (conference_editor:Scientific {name:conferences.Editor})
MERGE (conference_city:City {name:conferences.City})
MERGE (conference_edition:Conference_Edition {name:conferences.Edition})

MERGE (conference_author)-[:publish]->(conference_paper)
MERGE (conference_paper)-[:publishedON]->(conference)
MERGE (conference_paper)-[:edition]->(conference_edition)
MERGE (conference_edition)-[:AtYear]->(conference_year)
MERGE (conference)-[:city]->(conference_city)
MERGE (conference)-[:edits]->(conference_editor)
;

/* Create all the nodes realted with keywords */

LOAD CSV WITH HEADERS FROM 'file:///keywords_10.csv' AS keywords
MERGE (keyword:KeyWord {name:keywords.Keyword})
WITH keywords, keyword
MATCH (paper:Scientific_Paper)
WHERE paper.name = keywords.Paper
MERGE (paper)-[:HasKeyWord]->(keyword)
;


LOAD CSV WITH HEADERS FROM 'file:///reviews_10.csv' AS reviews
LOAD CSV WITH HEADERS FROM 'file:///references_10.csv' AS refers

WITH refers, reviews
MATCH (paper1:Scientific_Paper),(paper2:Scientific_Paper),(author:Scientific)-[:publish]->(author_paper:Scientific_Paper),(editor:Scientific),(paper_review:Scientific_Paper)
WHERE paper1.name = refers.paper AND paper2.name = refers.reference AND author.name = reviews.Author AND editor.name = reviews.Editor AND paper_review.name = reviews.Paper AND author_paper.name <> paper_review.name AND paper1.name <>  paper2.name
MERGE (paper1)-[:refersTo]->(paper2)
MERGE (editor)-[:Assigns_paper{name:paper_review.name}]->(author)
;
