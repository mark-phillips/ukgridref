// Of course irish and gb grids should be sub-classes but that blows the
// 16k memory limit for a simple datafield on most older devices
function create_gridref(lat,lon,precision) {
    return new OSGridRef(lat,lon, precision );
}