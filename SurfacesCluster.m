%
%
%  - Copy this file into the XTensions folder in the Imaris installation directory
%  - You will find this function in the Image Processing menu
%
%    <CustomTools>
%      <Menu>
%       <Submenu name="Surfaces Functions">
%        <Item name="Surfaces Cluster" icon="Matlab">
%          <Command>MatlabXT::SurfacesCluster(%i)</Command>
%        </Item>
%       </Submenu>
%      </Menu>
%      <SurpassTab>
%        <SurpassComponent name="bpSurfaces">
%          <Item name="Surfaces Cluster" icon="Matlab">
%            <Command>MatlabXT::SurfacesCluster(%i)</Command>
%          </Item>
%        </SurpassComponent>
%      </SurpassTab>
%    </CustomTools>
% 
%


function SurfacesCluster(aImarisApplicationID)

% connect to Imaris interface
if ~isa(aImarisApplicationID, 'Imaris.IApplicationPrxHelper')
  javaaddpath ImarisLib.jar
  vImarisLib = ImarisLib;
  if ischar(aImarisApplicationID)
    aImarisApplicationID = round(str2double(aImarisApplicationID));
  end
  vImarisApplication = vImarisLib.GetApplication(aImarisApplicationID);
else
  vImarisApplication = aImarisApplicationID;
end


% the user has to create a scene with some surfaces
vSurpassScene = vImarisApplication.GetSurpassScene;
if isequal(vSurpassScene, [])
  msgbox('Please create some Surfaces in the Surpass scene!');
  return;
end

% get the surfaces
vSurfaces = vImarisApplication.GetFactory.ToSurfaces(vImarisApplication.GetSurpassSelection);

% search the surfaces if not previously selected
if ~vImarisApplication.GetFactory.IsSurfaces(vSurfaces)        
  for vChildIndex = 1:vSurpassScene.GetNumberOfChildren
    vDataItem = vSurpassScene.GetChild(vChildIndex - 1);
    if isequal(vSurfaces, [])
      if vImarisApplication.GetFactory.IsSurfaces(vDataItem)
        vSurfaces = vImarisApplication.GetFactory.ToSurfaces(vDataItem);
      end
    end
  end
  % did we find the surfaces?
  if isequal(vSurfaces, [])
    msgbox('Please create some surfaces!');
    return;
  end
end

vNumberOfSurfaces = vSurfaces.GetNumberOfSurfaces;
vSurfacesName = char(vSurfaces.GetName);
vSurfaces.SetVisible(0);

vProgressDisplay = waitbar(0, 'Detecting clusters of surfaces');

vXYZ=zeros(vNumberOfSurfaces,3);

% Get Center of Mass XYZ coordinates for each Surface object
for vSurface = 0:vNumberOfSurfaces-1
  vXYZ(vSurface+1,:) = vSurfaces.GetCenterOfMass(vSurface);
  waitbar(vSurface/vNumberOfSurfaces)
end

disp(vXYZ)

% Run DBSCAN to detect clusters of Surface objects

scatter3(vXYZ(:,1),vXYZ(:,2),vXYZ(:,3),'.');
minpts = 5; % Minimum number of neighbors for a core point
% kD = pdist2(X,X,'euc','Smallest',minpts);
% plot(sort(kD(end,:)));
% title('k-distance graph')
% xlabel('Points sorted with 50th nearest distances')
% ylabel('50th nearest distances')
% grid
epsilon = 1;
labels = dbscan(vXYZ,epsilon,minpts);

disp(labels)

% create new group
vSurfacesGroup = vImarisApplication.GetFactory.CreateDataContainer;
vSurfacesGroup.SetName([vSurfacesName, ' clusters']);

for vSurface = 0:vNumberOfSurfaces-1
  vNewSurfaces = vSurfaces.CopySurfaces(vSurface);
  vNewSurfaces.SetName(sprintf('%s [%i]', vSurfacesName, vSurface + 1));

  vNewSurfaces.SetColorRGBA(floor((256^3)*rand));
  vSurfacesGroup.AddChild(vNewSurfaces, -1);

  waitbar(vSurface/vNumberOfSurfaces)
end

vSurpassScene.AddChild(vSurfacesGroup, -1);
close(vProgressDisplay);

