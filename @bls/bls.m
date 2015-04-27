% BLS BLS datafeed object constructor
%   C = BLS verifies that the URL
%   http://api.bls.gov/publicAPI/v2/timeseries/data is accessible and creates a
%   connection handle.
%
%   C = BLS(URL) creates the connection handle using the given URL. For
%   example, 'http://api.bls.gov/publicAPI/v2/timeseries/data'.
%   
%   C = BLS(URL, KEY) creates the connection handle using the given URL and API
%   registration key. For example,
%   'http://api.bls.gov/publicAPI/v2/timeseries/data'. The key, provided by
%   BLS, is usually a 32 hex-character string. A registration key allows more
%   daily requests and other functionality.
%
%   C = BLS([], KEY) creates the connection handle using the default URL and given API
%   registration key. 
%
%   See also FETCH

%   Author: Micah Smith
%   Date: April 2015

classdef bls
  properties
    url
    key
  end

  methods
    function obj = bls(url, key)
      % Default values
      DEFAULT_URL = 'http://api.bls.gov/publicAPI/v2/timeseries/data/';
      DEFAULT_KEY = [];

      % Set URL 
      if nargin>=1 & ~isempty(url)
        obj.url = url;
      else
        obj.url = DEFAULT_URL;
      end

      % Set API key
      if nargin==2
        obj.key = key;
      else
        obj.key = DEFAULT_KEY;
      end

      if nargin>2
        error('Too many input arguments.');
      end
    end % End of bls constructor
  end % End of methods block
end % End of classdef
