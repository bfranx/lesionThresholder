% addpath('./data')

%% threshold lesion on ADC map (ischemia; acute phase)
hdr = niftiinfo("data/subject19_tp1_mask.nii.gz");
csfthresh = 1.2; % completely arbritray intensity threshold for illustration purposes

adc1_im = niftiread("data/subject19_adc1.nii.gz");
includemask = niftiread("data/subject19_tp1_mask.nii.gz");
atlas_tp1 = niftiread("data/subject19_ROI34todwi1_nl.nii.gz");

myidx = [4, 14, 15, 17]; % these areas represent contralateral MCA irrigation area

excludemask = zeros(size(adc1_im));
excludemask(adc1_im>csfthresh)=1; % exclude 'csf' based on threshold defined above

mylesionmask = lesionThresholder(adc1_im,atlas_tp1,'searchidx',myidx,'includemask',includemask,'ignoremask',excludemask);

niftiwrite(mylesionmask,'data/subject19_adc1_lesion.nii',hdr,'Compressed',true) % save the mask
!fslview data/subject19_adc1.nii.gz data/subject19_adc1_lesion.nii.gz -l "Red"

%% threshold lesion on t2map (infarction; subacute phase)
t2map3_im = niftiread("data/subject19_t2map3.nii.gz");
adc3_im = niftiread("data/subject19_adc3.nii.gz");
includemask = niftiread("data/subject19_tp3_mask.nii.gz");
atlas_tp3 = niftiread("data/subject19_ROI34todwi1_nl.nii.gz");

excludemask = zeros(size(adc3_im));
excludemask(adc3_im>csfthresh)=1; % exclude 'csf' based on threshold defined above

mylesionmask = lesionThresholder(t2map3_im,atlas_tp3,'searchidx',myidx,'formula',"> MEAN + 2*STD", 'includemask',includemask,'ignoremask',excludemask);
niftiwrite(mylesionmask,'data/subject19_t2map3_lesion.nii',hdr,'Compressed',true) % save the mask
!fslview data/subject19_t2map3.nii.gz data/subject19_t2map3_lesion.nii.gz -l "Red"
