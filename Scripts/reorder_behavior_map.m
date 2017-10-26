% this script corrects the numbering of watershedding based on the names we
% came up with
load('reference_embedding.mat')

reordered_indecies = [4,5,1,6,2,3,9,7,8];

L = L + length(reordered_indecies) + 1;

for behavior_index = 1:length(reordered_indecies)
    L(L==behavior_index+length(reordered_indecies)+1) = reordered_indecies(behavior_index);
end

L(L==length(reordered_indecies)+1) = 0;
L(L==length(reordered_indecies)+length(reordered_indecies)+2) = length(reordered_indecies)+1;

behavior_names = {'Forward 1', 'Forward 2', 'Forward 3', 'Forward 4', 'Forward 5', 'Forward 6', ...
    'Slow Reverse', 'Fast Reverse', 'Turns'};
