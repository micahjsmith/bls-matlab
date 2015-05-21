bls-matlab
==========

A basic Matlab class to pull data from the Bureau of Labor Statistics using
their Public API [here](http://www.bls.gov/developers/home.htm).

Usage
-----

Basic usage:

    b = bls();
    data = fetch(b, 'LNS11000000');

Or, register on the BLS website for a Public Data API account
[here](http://data.bls.gov/registrationEngine/). Then, take advantage of the
increased daily query limit and other features:

    b = bls([], MY_API_KEY);
    data = fetch(b, 'PRS85006092', 'catalog', 'true');

Setup
-----

Navigate to a location where you store user-written Matlab code, such as:

    C:\Users\username\Documents\MATLAB
    /home/username/Documents/MATLAB

Run

    git clone https://github.com/micahjsmith/bls-matlab.git

That should do it. Check your `matlabpath` if you are having problems here.

Notes
------------

Requires Matlab 15a+ for the webservices/restful functionality. If you do not
have access to Matlab 15a+, then the `compatible-lt-15a` stable branch allows
you to enjoy this functionality at the expense of downloading the
[urlread2](http://www.mathworks.com/matlabcentral/fileexchange/35693-urlread2)
and
[JSONlab](http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave)
user-written packages from Mathworks File Exchange.
