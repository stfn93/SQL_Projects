SELECT title
FROM movies
JOIN stars ON movies.id = stars.movie_id
JOIN people ON stars.person_id = people.id
WHERE people.name IN ("Bradley Cooper", "Jennifer Lawrence")
GROUP BY title
HAVING COUNT(DISTINCT people.id ) = 2; --Ensures that only movies where both actors appear are included
