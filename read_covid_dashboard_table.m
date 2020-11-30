function T = read_covid_dashboard_table(path)
    opts = detectImportOptions(path);
    opts.VariableTypes{1}='datetime';
    T = readtable(path,opts);
end