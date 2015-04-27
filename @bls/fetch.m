function d = fetch(c,s,varargin)
% FETCH Request data from BLS.
%   D = FETCH(C,S) returns data for all fields from the BLS web site for given
%   series, S, given the connection handle, C.
% 
%   D = FETCH(C,S,D1) returns all data for the year D1.
%
%   D = FETCH(C,S,D1,D2) returns the data for the given series for the year 
%   range D1 to D2.
%
%   See also BLS

%   Author: Micah Smith
%   Date: April 2015

  %Input argument checking.
  if nargin < 2
    error('Connection object and security list required.');
  end

  %Validate series list.  Series list should be cell array string.
  if ischar(s)   
    s = cellstr(s);
  end
  if ~iscell(s) || ~ischar(s{1})
    error('Security list must be cell array of strings.');
  end

  %BLS requires uppercase series.
  s = upper(s);

  %Make recursive call for multiple series input.
  nSecurities = length(s);
  if nSecurities > 1
    for i = 1:nSecurities
      d(i) = fetch(c,s(i),varargin{:});
    end
    return
  end

  %Get initial url from connection handle.
  url = c.url;

  %Add series to URL, prepare request.
  url = [url, s{1}];
  headers = {'Content-type', 'application/json'};

  %Return data for requested date range.
  if nargin == 2
    % No date range provided.
    dates = {};

  else
    % Start year provided.
    if nargin == 3
      d1 = num2str(varargin{1});
      if regexp(d1, '\d\d\d\d')
        startyear = d1;
        endyear = d1;
      else
        error('D1 is a four-digit year.');
      end

    % End year provided.
    elseif nargin == 4
      d1 = num2str(varargin{1});
      d2 = num2str(varargin{2});
      if regexp(d1, '\d\d\d\d') && regexp(d2, '\d\d\d\d')
        startyear = d1;
        endyear = d2;
      else
        error('D1 and D2 are four-digit years.');
      end

    % Too many arguments.
    elseif nargin > 4
      error('Too many input arguments.')
    end

    dates = {'startyear', startyear, 'endyear', endyear};
  end

  % Try registration key
  if ~isempty(c.key)
    auth = {'registrationKey',c.key};
  else
    auth = {};
  end

  % Submit POST request to BLS.
  try
    tmp = urlread(url, 'post', {dates{:}, auth{:}, headers{:}});
  catch exception
    error('Error connecting to BLS servers.');
  end

  % Parse JSON.
  jsondata = loadjson(tmp);
  iSeries = 1;
  if strcmpi(jsondata.status,'REQUEST_SUCCEEDED')
    seriesId = jsondata.Results.series{iSeries}.seriesID;
    data = cellfun(@blsExtractDataField, jsondata.Results.series{iSeries}.data, 'un', 0);
    data = cell2mat(data');
    data = flipud(data);
  else
    seriesId = [];
    data = [];
    warning(sprintf('Request failed with message <''%s''>',jsondata.message{:}));
  end

  % Create output struct.
  d.SeriesID = seriesId;
  d.Data = data;

end % End of fetch function

% Extract the date, value pair from this struct.
function out = blsExtractDataField(field)
  value = str2num(field.value);

  year = str2num(field.year);
  period = field.period;
  % Monthly data
  if ~isempty(regexp(period, 'M\d\d')) && ~strcmp(period, 'M13') 
    myDate = datenum([year, str2num(period(2:3)),1]);

  % Quarterly data
  elseif regexp(period, 'Q\d\d')
    myDate = datenum([year, 3*str2num(period(3))-2, 1]);

  % Annual data
  elseif regexp(period, 'A\d\d')
    myDate = datenum([year,1,1]);

  % Not implemented.
  else
    myDate = NaN;
    warning('Data from period ',field.periodName, ' not implemented');
  end

  out = [myDate, value];
end
