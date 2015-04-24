bls-matlab
==========

A basic Matlab class to pull data from the Bureau of Labor Statistics using
their Public API [here](http://www.bls.gov/developers/home.htm).

Usage
-----

Basic usage:

    b = bls();
    data = fetch(b, 'CUUR0000SA0');

Or, register on the BLS website for a Public Data API account
[here](http://data.bls.gov/registrationEngine/). Then, take advantage of the
increased daily query limit and other features:

    b = bls([], MY_API_KEY);
    data = fetch(b, 'SUUR0000SA0');

Setup
-----

Navigate to a location where you store user-written Matlab code, such as:

    C:\Users\username\Documents\MATLAB
    /home/username/Documents/MATLAB

Run

    git clone https://github.com/micahjsmith/bls-matlab.git

That should do it. Check your `matlabpath` if you are having problems here.

Dependencies
------------

Requires the excellent JSONlab from Mathworks' File Exchange
[here](http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave).

You should be able to run `which loadjson` and see a path.
