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
    data = fetch(b, 'LAUCN040010000000005');

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

Requires Matlab 15a+ for the webservices/restful functionality.
