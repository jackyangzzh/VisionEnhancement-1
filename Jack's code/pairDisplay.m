function pairDisplay(index, sortedPairs_xyz)
if index>size(sortedPairs_xyz,1) || index < 1
   fprintf("Index out of bound.\n");
   return
end
showMetamers(sortedPairs_xyz(index,1:3),sortedPairs_xyz(index,4:6))