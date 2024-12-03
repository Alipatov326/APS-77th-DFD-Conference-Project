function PeopleDiffisionSS4
% Author: A. Lipatov
% Modified by: S.A. Suslov
% Last modified: 20.11.24
%--------------------------------------------------------------------------
clear, close all
fsz=16; lw=2;

r1 = [3 4 -5 5 5 -5 -8 -8 8 8];       
r2 = [3 4 -4.5 4.5 4 -4 -8 -8 -7.9 -7.9]; 
gdm = [r1; r2]';
g = decsg(gdm,'R1-R2',['R1'; 'R2']');

%Figure 1:
figure
pdegplot(g,EdgeLabels="on"); 
axis([-8.5 8.5 -8.5 8.5]);
title("",'interpreter','latex',...
    'FontSize',fsz)
set(gca,'Fontname','Times','FontSize',fsz-2)
model = femodel(AnalysisType="thermalSteady",Geometry=g);

model.EdgeBC(1) = edgeBC(Temperature=100);
model.EdgeBC(2) = edgeBC(Temperature=100);
model.EdgeBC(3) = edgeBC(Temperature=100);
model.EdgeBC(4) = edgeBC(Temperature=500);
model.EdgeBC(5) = edgeBC(Temperature=500);
model.EdgeBC(6) = edgeBC(Temperature=500);
%model.EdgeLoad(2) = edgeLoad(Heat=300);

model.MaterialProperties = materialProperties(ThermalConductivity=130);
model = generateMesh(model,Hmax=0.2);

%Figure 2:
figure 
pdemesh(model); axis equal
title("Finite element mesh",'interpreter','latex','FontSize',fsz)
set(gca,'Fontname','Times','FontSize',fsz-2)
R = solve(model); T = R.Temperature;

%Figure 3:
figure
pdeplot(R.Mesh,XYData=T,Contour="on",ColorMap="hot"); 
axis equal
title("Steady people density, persons per ???",'interpreter','latex',...
    'FontSize',fsz)
set(gca,'Fontname','Times','FontSize',fsz-2)
model.AnalysisType = "thermalTransient";
%model.AnalysisType = "thermalModal";

model.MaterialProperties.MassDensity = 20;
model.MaterialProperties.SpecificHeat = 3;

%model.EdgeBC(6) = ...
%edgeBC(Temperature= @transientBCHeatedBlock);
%EdgeBC(5) = edgeBC(Temperature=@transientBCHeatedBlock);
   
tlist = 0:.1:40;
model.FaceIC = faceIC(Temperature=100);
R = solve(model,tlist);
T = R.Temperature; msh = R.Mesh;

getClosestNode=@(p,x,y) min((p(1,:)-x).^2+(p(2,:)-y).^2);
[~,nid] = getClosestNode(msh.Nodes,.5,0);

%Figure 4:
h = figure;
h.Position = [1 1 2 1].*h.Position;
subplot(1,2,1); 
pdeplot(msh,XYData=T(:,end),Contour="on",ColorMap="autumn"); 
axis equal
set(gca,'Fontname','Times','FontSize',fsz-2)
title("",...
    'interpreter','latex','FontSize',fsz)
subplot(1,2,2); 

plot(tlist, T(nid,:),'LineWidth',lw);

xticks([0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40])
yticks([100 105 110 115 120 125 130 135 140 145])
yt = get(gca, 'YTick');
set(gca,'YTickLabel',yt-100)
grid(gca,'minor')
set(gca,'XMinorTick','on')
set(gca,'YMinorTick','on')
            % Get the data (Modify)
%h = plot(tlist, T(nid,:),'LineWidth',lw);
%ax=gca;       
%ax.XTick(1) = h.XData(1) - 100;

%set(y, 'Units', 'Normalized', 'Position', [-0.1, 0.5, 0]);
%dy=-1;
%ylh.Position(1)=ylh.Position(1)-dy;

grid on

set(gca,'Fontname','Times','FontSize',fsz-2)
title("",'interpreter','latex',...
    'FontSize',fsz)
xlabel("Time (years)",'interpreter','latex','FontSize',fsz)
ylabel("People in million",'interpreter','latex',...
    'FontSize',fsz)
end