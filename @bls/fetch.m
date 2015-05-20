function d = fetch(c,s,varargin)
% FETCH Request data from BLS.
%   D = FETCH(C,S) returns data from the BLS API for a given series or cell
%   array of series, S, and connection handle, C.
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
  options = weboptions('MediaType','application/json');
  dates = {'startyear', startYear, 'endyear', endYear};
  params = {'catalog', catalog};
  
  % Try registration key
  if ~isempty(c.key)
    auth = {'registrationKey',c.key};
  else
    auth = {};
  end
  
  data = struct('seriesid',{s}, ...
                dates{:}, ...
                params{:}, ...
                auth{:});
            
  % Submit POST request to BLS.
  try
    response = webwrite(url, data, options);
  catch err
    error('Error connecting to BLS servers.');
  end

  % Response okay?
  if ~strcmpi(response.status,'REQUEST_SUCCEEDED')
    warning('Request failed with message ''%s''',response.message{:});
    d.SeriesID = [];
    d.Data = [];
    return;
  end
  
  % Parse response.
  nSeries = length(response.Results.series);
  for iSeries = 1:nSeries
    seriesId = response.Results.series(iSeries).seriesID;
    data = arrayfun(@blsExtractDataField, ...
                    response.Results.series(iSeries).data, 'un', 0);
    data = cell2mat(data);
    data = flipud(data);
    d(iSeries).SeriesID = seriesId;
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
    myDate = NaN;
    error(['Data from period ',field.periodName, ' not implemented']);
  end

  out = [myDate, value];
end
