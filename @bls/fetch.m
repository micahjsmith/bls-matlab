function d = fetch(c,s,varargin)
% FETCH Request data from BLS.
%   D = FETCH(C,S) returns data from the BLS API for a given series or cell
%   array of series, S, and connection handle, C. Defaults to last 10 years of
%   data.
% 
%   D = FETCH(C,S,D1) returns data for the year D1 to present.
%
%   D = FETCH(C,S,D1,D2) returns data for the for the year range D1 to D2.
%
%   D = FETCH(___, 'Name', 'Value', ...) returns data given the name, value
%   pairs. Currently, the only pair supported is 'catalog', 'true'.
%
%   See also BLS

%   Author: Micah Smith
%   Date: April 2015

  % Constants
  BLS_RESPONSE_SUCCESS = 'REQUEST_SUCCEEDED';
  BLS_RESPONSE_CATALOG_FAIL = 'unable to get catalog data';
  FAKE_SERIES_NAME = '!@#$%^&*()';
  
  % Validate arguments
  validCatalogTrue = {'true','on'};
  validCatalogFalse = {'false','off'};
  validCatalog = {validCatalogTrue{:}, validCatalogFalse{:}};
  defaultCatalog = 0;
  defaultEndYear = datestr(now(), 'yyyy');
  defaultStartYear = num2str(str2double(defaultEndYear)-9);
  validationYear = ...
    @(x) (ischar(x) && regexp(x, '\d\d\d\d')) || ...
         (isnumeric(x) && isscalar(x) && (x>=1900));
  validationCatalog = ...
    @(x) (ischar(x) && any(strcmpi(x, validCatalog))) || ...
         (isnumeric(x) && isscalar(x));
  validationSeries = ...
    @(x) ischar(x) || iscellstr(x);
  p = inputParser();
  addRequired(p, 's', validationSeries);
  addOptional(p, 'startyear', defaultStartYear, validationYear);
  addOptional(p, 'endyear', defaultEndYear, validationYear);
  addParameter(p, 'catalog', defaultCatalog, validationCatalog);
  parse(p, s, varargin{:});
  startYear = p.Results.startyear;
  endYear = p.Results.endyear;
  if ischar(p.Results.catalog) && ...
     any(strcmpi(p.Results.catalog, validCatalogTrue))
    catalog = 1;
  elseif isnumeric(p.Results.catalog) && p.Results.catalog > 0
    catalog = 1;
  else
    catalog = 0;
  end
  
  % BLS specifies uppercase series.
  if ischar(s)
    s = cellstr(s);
  end
  s = upper(s);
  
  % Stup request and payload.
  url = c.url;
  header.name = 'Content-Type';
  header.value = 'application/json';
  dates = {'startyear', startYear, 'endyear', endYear};
  params = {'catalog', catalog};
  
  % Try registration key
  if ~isempty(c.key)
    auth = {'registrationKey',c.key};
  else
    auth = {};
  end
  
  % Encode json string. Workaround for bug that single series not encoded as
  % list by savejson.
  if length(s)==1
    s{end+1} = FAKE_SERIES_NAME;
    hasFakeString = 1;
  else
    hasFakeString = 0;
  end
  data = savejson('',struct('seriesid',{s},dates{:},params{:},auth{:}), 'Compact', 1);
  if hasFakeString
    data = strrep(data, [',"',FAKE_SERIES_NAME,'"'],'');
    %s{end} = [];
  end

  % Submit POST request to BLS.
  try
    responseJson = urlread2(url, 'POST', data, header);
  catch err
    disp(err);
    error('Error connecting to BLS servers.');
  end

  response = loadjson(responseJson);

  % Response okay?
  if ~strcmpi(response.status,BLS_RESPONSE_SUCCESS)
    warning('Request failed with message ''%s''',response.message{:});
    d.SeriesID = [];
    d.Data = [];
    return;
  end
  
  % Catalog okay?
  if catalog && ...
     ~isempty(response.message) && ...
     any(cell2mat(strfind(lower(response.message), BLS_RESPONSE_CATALOG_FAIL)))
    catalogOkay = 0;
  else
    catalogOkay = 1;
  end
  
  % Parse response.
  nSeries = length(response.Results.series);
  for iSeries = 1:nSeries
    d(iSeries).SeriesID = response.Results.series{iSeries}.seriesID;

    if catalog 
      if catalogOkay
        d(iSeries).Catalog = response.Results.series{iSeries}.catalog;
      else
        d(iSeries).Catalog = [];
      end
    end
    
    data = cellfun(@blsExtractDataField, ...
                    response.Results.series{iSeries}.data, 'un', 0);
    data = data';
    data = cell2mat(data);
    data = flipud(data);
    d(iSeries).Data = data;
  end

end % End of fetch function

% Extract the date, value pair from this struct.
function out = blsExtractDataField(field)
  value = str2double(field.value);

  year = str2double(field.year);
  period = field.period;
  % Monthly data
  if ~isempty(regexp(period, 'M\d\d', 'once')) && ~strcmp(period, 'M13') 
    myDate = datenum([year, str2double(period(2:3)),1]);

  % Quarterly data
  elseif regexp(period, 'Q\d\d')
    myDate = datenum([year, 3*str2double(period(3))-2, 1]);

  % Annual data
  elseif regexp(period, 'A\d\d')
    myDate = datenum([year,1,1]);

  % Not implemented.
  else
    error(['Data from period ',field.periodName, ' not implemented']);
  end

  out = [myDate, value];
end
