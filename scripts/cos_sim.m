% Cosine similarity
% https://en.wikipedia.org/wiki/Cosine_similarity

function s = cos_sim(u, v)
    s = (dot(u,v)) / (norm(u)*norm(v));
end