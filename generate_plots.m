function generate_plots(varargin)
    p=inputParser;
    p.addParameter('errorbar',false);
    p.parse(varargin{:});
    params=p.Results;
    P=get_parameters;
    csv_files = dir(fullfile(P.repository_path,'data'));
    csv_files = {csv_files.name};
    csv_files = csv_files(endsWith(csv_files,'.csv'));
    if numel(csv_files)<1
        warning('No CSV files found in %s.',fullfile(P.repository_path,'data'));
        return
    end
    figure('Position',P.figure_position);
    colors = distinguishable_colors(length(csv_files)+1);
    for i=1:length(csv_files)+1
        if i>length(csv_files)
            if ( length(unique(cat(1,dates{:}))) == length(dates{1}) ) && numel(unique(cellfun(@height,T)))==1
                dates{i} = dates{1};
                n_tests{i} = sum([n_tests{:}],2);
                n_pos{i} = sum([n_pos{:}],2);     
                names{i} = 'Combined';
            else
                warning('Dates are not the same in all tables. Will not combine them.');
                continue
            end
        else
            [~,names{i},~] = fileparts(csv_files{i});         
            T{i} = read_covid_dashboard_table(csv_files{i});
            dates{i} =  T{i}.WeekEnding;
            n_tests{i} = T{i}.Tests;
            n_pos{i} = T{i}.PositiveCases;
        end
        if params.errorbar
            [~,l,u] = bino_confidence(n_tests{i},n_pos{i});
            l(isnan(l))=0;
            h(i) = shadedErrorBar(datenum(dates{i}),100*n_pos{i}./n_tests{i},100*[u l]');hold on;
            h(i).mainLine.Color = colors(i,:);
            h(i).mainLine.LineWidth=2;
            h(i).mainLine.Marker='.';
            h(i).mainLine.MarkerSize=20;
            h(i).patch.FaceAlpha = 0.5;
            h(i).patch.FaceColor = colors(i,:);
            if i>length(csv_files)
                h(i).mainLine.LineStyle=':';
            end
        else
            h(i) = plot(datenum(dates{i}),100*n_pos{i}./n_tests{i},'color',colors(i,:),'LineWidth',2,'Marker','.','MarkerSize',20);hold on;   
            if i>length(csv_files)
                h(i).LineStyle=':';
            end
        end
    end
    if params.errorbar
       legend([h.mainLine],names);
    else
       legend(h,names); 
    end
    set(gca,P.axes_properties{:});
    all_dates = datenum(unique([dates{:}]));
    yl=get(gca,'ylim');
    set(gca,'xlim',[min(all_dates) max(all_dates)],'xtick',all_dates(1:2:end),'ytick',[0:0.5:max(1,yl(2))],'ylim',[0 max(1,yl(2))]);
    datetick('x', 'mmm-dd-yy','keeplimits','keepticks');    
    ylabel('% Positivity Rate');
    xlabel('Week Ending');
    for i=1:length(P.figure_image_format)
        saveas(gcf,fullfile(P.repository_path,'plot'),P.figure_image_format{i});
    end
end