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

        Hz=(strcmp('wasp',char(insect(species)))*5000)+(~strcmp('wasp',char(insect(species)))*2000); %apply Hz the frequency according to the insectspecies
        accumulated_data=[]; %reset storage
        for trial=1:size(data,2) %for each trial of current combination of experiment-species
            %% decrease sample rate to 200Hz which is approxemly a flapping cycle 
            decrease_ratio=1/(200/Hz); %decrease sample rate to 200Hz
            for dim=1:3 %for each axis
                V(:,dim)=data(trial).aerial_velocity(:,dim); %extract axis speed
                decimation_index=1:decrease_ratio:length(V(:,dim)); %data between this indices in original sample will reduced to one sample
                if length(decimation_index)==1 %if data isn't long enough for more than 1 data point after decrease of sample rate
                    V_decimated(1,dim)=median(V(:,dim)); %reduce sample rate by calc median for all the data
                else
                    for decimation=2:length(decimation_index) %Gal prefered manually decimation rather than using Matlab 'decimate' function 
                        V_decimated(decimation-1,dim)=median(V(decimation_index(decimation-1):decimation_index(decimation),dim)); %reduce sample rate by calc median of the current range of data
                    end
                end
            end
            Vxy=sqrt((V_decimated(:,1).^2)+(V_decimated(:,2).^2)); %calc horizontal velocity
            Vz=V_decimated(:,3);
            clearvars V decimation_index V_decimated
            %% spline of data after excluding extremes 
%             time_line=(1/Hz):(1/Hz):(1/Hz)*length(data(trial).aerial_velocity(:,1));
%             for dim=1:3 %for each axis
%                 V(:,dim)=data(trial).aerial_velocity(:,dim); %extract axis speed
%                 axes_extremes_excluded(:,dim)=abs(V(:,dim))<=prctile(abs(V(:,dim)),90); %index of frames with values of 90% or less from max 
%             end
%             extremes_excluded=axes_extremes_excluded(:,1)&axes_extremes_excluded(:,2)&axes_extremes_excluded(:,3); %frames index that are not exluded in all axes
%             for dim=1:3 %for each axis
% %                 pp=spline(time_line(extremes_excluded),[V((find(extremes_excluded,1,'first')),dim);V((extremes_excluded),dim);V((find(extremes_excluded,1,'last')),dim)]'); %fit a curved function to original data after exluding extreme values 
%                 pp=pchip(time_line(extremes_excluded),V((extremes_excluded),dim)); %fit a function, without overshoot, to original data after exluding extreme values 
%                 Vinterpolated(:,dim)=ppval(pp,time_line(find(extremes_excluded,1,'first'):find(extremes_excluded,1,'last'))); %extract values to each frame in the timeline according to the function. Trim time line is edges are extreme values
%             end
%             Vxy=sqrt((Vinterpolated(:,1).^2)+(Vinterpolated(:,2).^2)); %calc horizontal velocity
%             Vz=Vinterpolated(:,3);
%             clearvars V axes_extremes_excluded Vinterpolated
            accumulated_data((length(accumulated_data)+1):(length(accumulated_data)+length(Vxy)),:)=[Vxy,Vz]; %storage of trials in this experiment-species combination
%             scatter(Vxy,Vz,'.k') %plot trial as black dots of current trial
        end
        if ~isempty(accumulated_data) %skip vertical wasp combination
            scatterhist(accumulated_data(:,1),accumulated_data(:,2),'Direction','out')
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
%% save figures
% for k=1:8 %for each figure
%     figure(k)
%     axis equal
%     xlim(axis_limits(1:2)) %set X axis limits from zero to maximal X upper limit from all figures
%     ylim(axis_limits(3:4)) %set Y axis limits from minimal Y lower limit to maximal X upper limit from all figures
%     hgsave(sprintf('%s_%s',char(type(ceil((k/4)))),char(insect(k-(4*abs(1-ceil(k/4)))))))
% end
