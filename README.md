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

1. Navigate to a location where you store user-written Matlab code, such as:

    C:\Users\username\Documents\MATLAB
    /home/username/Documents/MATLAB

2. Run

    git clone https://github.com/micahjsmith/bls-matlab.git

3. Install JSONlab from
   [here](http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave)
   and ensure that it is visible on your `matlabpath`.

4. Install urlread2 from
   [here](http://www.mathworks.com/matlabcentral/fileexchange/35693-urlread2)
   and ensure that it is visible on your `matlabpath`.



Notes
------------

This branch facilitates usage of the package on Matlab before 15a by using the user packages
`JSONlab` and `urlread2` to substitute for the missing `webread`.
