# bls-matlab

A basic Matlab class to pull data from the Bureau of Labor Statistics using
their Public API [here](http://www.bls.gov/developers/home.htm).

## Usage

Basic usage:

```matlab
b = bls();
data = fetch(b, 'LNS11000000');
```

Or, register on the BLS website for a Public Data API account
[here](http://data.bls.gov/registrationEngine/). Then, take advantage of the
increased daily query limit and other features:

```matlab
b = bls([], MY_API_KEY);
data = fetch(b, 'PRS85006092', 'catalog', 'true');
```

For full documentation, see the inline help:

```matlab
help bls
help bls.fetch
```

## Setup

Navigate to a location where you store user-written Matlab code, such as:

```
C:\Users\username\Documents\MATLAB
/home/username/Documents/MATLAB
```

Run

```
git clone https://github.com/micahjsmith/bls-matlab.git
```

Add to MATLAB path (from command window):

```matlab
addpath(genpath('/absolute/path/to/bls-matlab'))
```

That should do it. Check your `matlabpath` if you are having problems here. Add the above command to your `startup.m` file to have bls-matlab available every time you use MATLAB.

## Notes

### Alternatives

* The [BlsData.jl](https://github.com/micahjsmith/BlsData.jl) package (by the same author) provides expanded functionality for pulling from BLS in [Julia](julialang.org).

* The [FredData.jl](https://github.com/micahjsmith/FredData.jl) package (by the same author) provides functionality for pulling from Fred in Julia which provides access to almost all BLS series, albeit with different series IDs.

### Limitations

* the BLS API enforces limits on requests - see [here](https://github.com/micahjsmith/BlsData.jl#notes) for a summary
* the BLS API exposes only 10 years of data at once; if you request more than this, your request will be truncated. At this point, bls-matlab does not automatically make multiple requests to handle this situation, you must batch your requests yourself.
* I don't use MATLAB anymore and have limited capacity for maintenance - are you a motivated user of bls-matlab? [Email me](https://www.micahsmith.com/contact/) about helping with maintenance of this project.

### Compatibility

* tested on 2019a
* requires >2015a for the webservices/restful functionality.
* for pre-2015a usage, see the `compatible-lt-15a` branch which allows you to enjoy this functionality at the expense of downloading the [urlread2](http://www.mathworks.com/matlabcentral/fileexchange/35693-urlread2) and [JSONlab](http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave) user-written packages from Mathworks File Exchange. This branch has not received any further development or bug fixes.
