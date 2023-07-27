function lesionmask = lesionThresholder(imin,atlas,varargin)

% Create a mask [0-1] based on deviance from values of an internal
% reference. It will label voxels that are two times lower than some
% control mean, but other thresholds can be passed to the function.
%
% Useful for semi-automatic lesion delineation
% 
% Obligatory input:
%  imin         : matrix representing your image (currently 3D only!)
%  atlas        : mask of your reference areas (typically parcelated atlas  (currently 3D only!)
% Optional input:
%  searchidx    : control areas from which mean is sampled [1]
%  includemask  : mask [0-1] covering tissue of interest (e.g. brain)
%  ignormask    : mask [0-1] indicating tissue that should be ignored (e.g. csf)
%  formula      : formula that defines the threshold: default is " < (MEAN - 2*STD) ", so voxels LOWER than some mean minus twice the standard deviation, sampled from the atlas voxels with values specificied by "searchidx"
%  holeflag     : fill holes in lesion mask: y/n [n]
%
% Output:
%  lesionmask   : matrix containing [0-1] of voxels that exceed the (user-defined) threshold

% Author: bfranx 
% v0.1.0

maskvalidationFcn = @(x) all(ismember(x,[0 1]),'all');

p = inputParser;
p.KeepUnmatched = false;
p.FunctionName = 'lesionThresholder';
addRequired(p,'imin', @isnumeric)
addRequired(p,'atlas', @isnumeric)
addParameter(p,'searchidx', 1, @isnumeric)
addParameter(p,'includemask', [], maskvalidationFcn)
addParameter(p,'ignoremask', [], maskvalidationFcn)
addParameter(p,'formula', "< (MEAN - 2*STD)", @isstring)
addParameter(p,'holeflag', 'n', @ischar)

parse(p, imin, atlas, varargin{:})

if size(imin)~=size(atlas)
    error('Image and atlas dimensions do not match!')
end

if ~isempty(p.Results.includemask)
    imin(p.Results.includemask==0)=NaN; % all voxels outside includemask set to NaN so they won't contribute to averaging process
end

if ~isempty(p.Results.ignoremask)
    imin(p.Results.ignoremask==1)=NaN;
end

indices=find(ismember(atlas(:,:,:), p.Results.searchidx)); % all voxels inside ignoremask set to NaN so they won't contribute to averaging process

MEAN = mean(imin(indices), 'omitnan');
STD = std(imin(indices), 'omitnan');

% indexlesion = imin < (MEAN - 2*STD); % formula needs to go here
myexpr = ['indexlesion = imin ', p.Results.formula];
eval(join(myexpr));
lesionmask = zeros(size(imin));
lesionmask(indexlesion)=1;

% fill holes (requires image processing toolbox)
switch p.Results.holeflag
    case 'y'
        for slice=1:size(lesionmask,3)
            lesionmask(:,:,slice)=imfill(lesionmask(:,:,slice),'holes');
        end
    otherwise
        %nothing
end

% TODO: implement solution to cluster based on spatial
% contiguity -> exclude smaller groups of false positives

lesionmask = single(lesionmask);
            
            
            
