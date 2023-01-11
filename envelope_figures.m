clear
close all
load('D:\GalR10\Desktop\OneDrive - Tel-Aviv University\Publications\Wind tunnel\all_wind_tunnel_data.mat') %load data
type={'horizontal'; 'vertical'}; %experiments type
insect={'wasp'; 'whitefly'; 'thrips'; 'beetle'}; %insects species
axis_limits=[0,0,0,0]; %inital figure limits
for experiment=1:size(type,1) %for each experiments type
    for species=1:size(insect,1) %for each species 
        figure; hold on; %create figure for each experiment-species combination
        data=eval(sprintf('wind_tunnel.%s.%s',char(type(experiment)),char(insect(species)))); %extract current combination data      
        for trial=1:size(data,2) %for each trial of current combination
            Hz=(strcmp('wasp',char(insect(species)))*5000)+(~strcmp('wasp',char(insect(species)))*2000); %apply Hz the frequency according to the insectspecies
            time_line=(1/Hz):(1/Hz):(1/Hz)*length(data(trial).aerial_velocity(:,1));
            for dim=1:3 %for each axis
                V(:,dim)=data(trial).aerial_velocity(:,dim); %extract axis speed
                axes_extremes_excluded(:,dim)=abs(V(:,dim))<=prctile(abs(V(:,dim)),90); %index of frames with values of 90% or less from max 
            end
            extremes_excluded=axes_extremes_excluded(:,1)&axes_extremes_excluded(:,2)&axes_extremes_excluded(:,3); %frames index that are not exluded in all axes
            %% spline of data after extremes excluded
            for dim=1:3 %for each axis
%                 pp=spline(time_line(extremes_excluded),[V((find(extremes_excluded,1,'first')),dim);V((extremes_excluded),dim);V((find(extremes_excluded,1,'last')),dim)]'); %fit a curved function to original data after exluding extreme values 
                pp=pchip(time_line(extremes_excluded),V((extremes_excluded),dim)); %fit a function, without overshoot, to original data after exluding extreme values 
                Vinterpolated(:,dim)=ppval(pp,time_line(find(extremes_excluded,1,'first'):find(extremes_excluded,1,'last'))); %extract values to each frame in the timeline according to the function. Trim time line is edges are extreme values
            end
            Vxy=sqrt((Vinterpolated(:,1).^2)+(Vinterpolated(:,2).^2)); %calc horizontal velocity
            scatter(Vxy,Vinterpolated(:,3),'.k') %plot trial as black dots
            %% compare original to interpolation
%             figure
%             hold on
%             Vxy_o=sqrt((V(:,1).^2)+(V(:,2).^2)); %calc horizontal velocity
%             plot(Vxy_o,'k')
%             plot(find(extremes_excluded),Vxy_o(extremes_excluded),'*k')
%             plot(Vxy,'b')
%             figure
%             hold on
%             plot(V(:,3),'k')
%             plot(find(extremes_excluded),V(extremes_excluded,3),'*k')
%             plot(Vinterpolated(:,3),'b')
            %%
            clearvars V axes_extremes_excluded Vinterpolated
        end
        current_axis=axis; %recieve figure's axis limits
        axis_limits(2)=[current_axis([false,current_axis(2)>axis_limits(2),false,false]),axis_limits([false,current_axis(2)<=axis_limits(2),false,false])]; %store current X axis upper limit if it is larger then all figures before
        axis_limits(3)=[current_axis([false,false,current_axis(3)<axis_limits(3),false]),axis_limits([false,false,current_axis(3)>=axis_limits(3),false])]; %store current Y axis lower limit if it is smaller then all figures before
        axis_limits(4)=[current_axis([false,false,false,current_axis(4)>axis_limits(4)]),axis_limits([false,false,false,current_axis(4)<=axis_limits(4)])]; %store current Y axis upper limit if it is larger then all figures before
        title(sprintf('%s wind tunnel: %s',char(type(experiment)),char(insect(species)))) %add title according to current experiment-species combination
        xlabel('Horizontal aerial speed (m/s)')
        ylabel('Vertical aerial velocity (m/s)')
    end
end
for k=1:8 %for each figure
    figure(k)
    axis equal
    xlim(axis_limits(1:2)) %set X axis limits from zero to maximal X upper limit from all figures
    ylim(axis_limits(3:4)) %set Y axis limits from minimal Y lower limit to maximal X upper limit from all figures
    hgsave(sprintf('%s_%s',char(type(ceil((k/4)))),char(insect(k-(4*abs(1-ceil(k/4)))))))
end
