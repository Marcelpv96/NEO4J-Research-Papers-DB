/* First of all load load data from CSV */
LOAD CSV WITH HEADERS FROM 'file:///journals_150.csv' AS journals


/* Create all the nodes related with JOURNAL and relations */
MERGE (journal_author:Scientific {name:journals.Author, age:journals.Age, dni:journals.Dni})
MERGE (journal:Journal {name:journals.Journal})
MERGE (journal_year:Year {year:journals.Year})
MERGE (journal_paper:Scientific_Paper {name:journals.Paper, ISBN:journals.Isbn, Pages:journals.Pages})
MERGE (journal_editor:Scientific {name:journals.Editor, age:journals.EditorAge, dni:journals.EditorDni})
MERGE(volume:Volume {name:journals.Edition, year:journals.Year})

MERGE (journal_author)-[:writes]->(journal_paper)
MERGE (journal_paper)-[:publishedON]->(volume)
MERGE (journal)-[:edit_by]->(journal_editor)
MERGE (journal)<-[:isEdition]-(volume)

WITH count(*) as dummy

MATCH (year:Year), (edition:Volume)
WHERE year.year = edition.year
MERGE (edition)-[:AtYear]->(year)


WITH count(*) as dummy


/* Create all the nodes_related with CONFERENCE and relations*/
LOAD CSV WITH HEADERS FROM 'file:///conferences_150.csv' AS conferences
MERGE (conference_author:Scientific {name:conferences.Author, age:conferences.Age, dni:conferences.Dni})
MERGE (conference:Conference {name:conferences.Conference})
MERGE (conference_year:Year {year:conferences.Year})
MERGE (conference_paper:Scientific_Paper {name:conferences.Paper, ISBN:conferences.Isbn ,pages:conferences.Pages})
MERGE (conference_editor:Scientific {name:conferences.Editor, age:conferences.EditorAge, dni:conferences.EditorDni})
MERGE (conference_city:City {name:conferences.City})
MERGE (proceeding:Proceeding {name:conferences.Edition, year:conferences.Year})

MERGE (conference_author)-[:writes]->(conference_paper)
MERGE (conference_paper)-[:publishedON]->(proceeding)
MERGE (proceeding)-[:city]->(conference_city)
MERGE (conference)-[:edits]->(conference_editor)
MERGE (conference)<-[:isEdition]-(proceeding)

WITH count(*) as dummy

MATCH (year:Year), (edition:Proceeding)
WHERE year.year = edition.year
MERGE (edition)-[:AtYear]->(year)

WITH count(*) as dummy

/* Create all the nodes realted with keywords */
LOAD CSV WITH HEADERS FROM 'file:///keywords_150.csv' AS keywords
MERGE (keyword:KeyWord {name:keywords.Keyword})
WITH keywords, keyword
MATCH (paper:Scientific_Paper)
WHERE paper.name = keywords.Paper
MERGE (paper)-[:HasKeyWord]->(keyword)

WITH count(*) as dummy

/* Create all nodes related with references */
LOAD CSV WITH HEADERS FROM 'file:///references_150.csv' AS refers
WITH refers
MATCH (paper:Scientific_Paper),(reference:Scientific_Paper)
WHERE paper.name = refers.paper AND reference.name = refers.reference AND paper.name <> reference.name
MERGE (paper)-[:refersTo]->(reference)

WITH count(*) as dummy

/* Create all nodes related with reviews */
LOAD CSV WITH HEADERS FROM 'file:///reviews_150.csv' AS reviews
MATCH (author:Scientific)-[:writes]->(paper_review:Scientific_Paper), (reviewer:Scientific), (editor:Scientific)
WHERE paper_review.name = reviews.Paper AND reviewer.name = reviews.Author AND reviewer.name <> author.name AND editor.name = reviews.Editor
MERGE (editor)-[:Assigns_paper{name:paper_review.name}]->(reviewer)
;
