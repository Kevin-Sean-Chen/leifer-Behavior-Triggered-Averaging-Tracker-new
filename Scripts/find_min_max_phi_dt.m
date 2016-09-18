for spectra_index = 1:length(Spectra)
    difference = abs(Spectra{spectra_index} - old_Spectra{spectra_index});
    differences(spectra_index) = sum(difference(:));
    
end
sum(differences)