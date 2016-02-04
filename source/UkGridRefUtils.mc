using Toybox.Math;
using Toybox.System;

class UkGridRefUtils
{
    var valid = false;
    var text = "Outside UK?";       // Grid ref square - e.g. SU
    var easting = "????";    // Grid ref easting
    var northing = "????";   // Grid ref northing
    var precision = 10;  // Grid ref precision - 6 or 10
    var latitude = 0.0;
    var longitude = 0.0;
    var alpha = ["A","B","C","D","E","F","G","H","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
    var deg2rad = Math.PI / 180;
    var rad2deg = 180.0 / Math.PI;

  // Create grid ref from WSG84 lat /long
  function initialize(lat, lon, p )
  {
    if (lat == null or lon == null) {
        return;
    }
    latitude = lat.toFloat();
    longitude = lon.toFloat();
    if (p != 6 and p != 8 and p != 10) 
    {
      System.println("Incorrect precision value (" + p + ")- must be one of: 6, 8 or 10.  Default of 10 will be used" );
      p = 10;
    }
    precision = p;
    //
    // Check we have a valid UK lat & long
    if (lon.toNumber() < -10 or lon.toNumber() > 4 or lat.toNumber() < 49.5 or lat.toNumber() > 62) {
        valid = false;
    }
    //
    // Looks good so far so convert to Eastings & Northings
    else {
       valid = true;
       var numeric_grid_ref = OSBG36_latlon_to_numeric_gridref(  WSG84_to_OSGB36(lat,lon) );
       if (numeric_grid_ref[0] < 0 or numeric_grid_ref[1] < 0)
       {
         valid = false;
       }
       //
       // Got a valid numberic Eastings and Northings GR so convert to text grid ref
       else
       {
           var text_grid_ref = toGridRef(numeric_grid_ref[0], numeric_grid_ref[1], precision, valid);
           text = text_grid_ref[0];
           easting = text_grid_ref[1];
           northing = text_grid_ref[2];
           valid = text_grid_ref[3];
       }
    }
  }

  function getGR () {
    return [text, easting , northing, valid];
  }
    //  Convert numeric Easting and Northing to a Grid Ref
    //   - Based on http://www.jstott.me.uk/jscoord/  -  toSixFigureString()
    //  Returns 4 element array: [t,e,n,valid] -  text, easting, northing, valid
    function toGridRef(east, north, precision, valid)
    {
          var t = "";
          var e = "";
          var n = "";
    //System.println("numeric grid "  + east.toString() + "," + north.toString() );
          //
          // Easting & Northing must be >= 0
          if (valid == true && east >= 0 && north >= 0)
          {
            var hundredkmE = floor(east.toDouble() / 100000);
            var hundredkmN = floor(north.toDouble() / 100000);
            var firstLetter = "";
            if (hundredkmN < 5) {
              if (hundredkmE < 5) {
                firstLetter = "S";
              } else {
                firstLetter = "T";
              }
            } else if (hundredkmN < 10)
            {
              if (hundredkmE < 5) {
                firstLetter = "N";
              } else {
                firstLetter = "O";
              }
            } else {
              firstLetter = "H";
            }

            var secondLetter = "";
            var index =  ((4 - (hundredkmN % 5)) * 5) + (hundredkmE % 5);
            //System.println("index: " + index );
            if (index >= 0 && index < alpha.size() )
            {
              secondLetter = alpha[index.toNumber()];
              var format_string = "%0" + precision/2 + "u"; // zero fill format 
              var precision_modifier = 1; // Default to 10 figure grid ref 
              if (precision == 6)   // For 6 figure grid ref drop last 2 digits
              {
                 precision_modifier = 100; 
              }
              else if (precision == 8)  // For 8 figure grid ref drop last digit
              {
                 precision_modifier = 10; 
              }
              e = ((east - (100000 * hundredkmE)) / precision_modifier).format(format_string);  
              n = ((north - (100000 * hundredkmN)) / precision_modifier).format(format_string);
              t = (firstLetter+secondLetter);
              valid = true;
            }
            else {
                valid = false;
            }
        }

        if (valid == false) {
            t = "Outside UK?";
            e = "????";
            n = "????";
        }
        return [t,e,n,valid]; // text, easting, northing, valid
    }


    function WSG84_to_OSGB36(lat,lon)
    {
         var WGS84_AXIS = 6378137;
         var WGS84_ECCENTRIC = 0.00669438037928458;
         var OSGB_AXIS = 6377563.396;
         var OSGB_ECCENTRIC = 0.0066705397616;
         var phip = lat * deg2rad;
         var lambdap = lon * deg2rad;
    //System.println("WSG84 latitude, longitude: " + lat.toString() + "," + lon.toString() );
         var OSGB36_coords = transform_datum(phip, lambdap, WGS84_AXIS, WGS84_ECCENTRIC, OSGB_AXIS, OSGB_ECCENTRIC);
    //System.println("OSGB36 latitude, longitude: " + OSGB36_coords[0].toString() + "," + OSGB36_coords[1].toString() );
         return OSGB36_coords ;
    }

    //function transform_datum(lat, lon, a, e, h, a2, e2, xp, yp, zp, xr, yr, zr, s)
    function transform_datum(lat, lon, a, e, a2, e2)
    {
        var xp = -446.448;
        var yp =  125.157;
        var zp =  -542.06;
        var xr = -0.1502;
        var yr = -0.247;
        var zr = -0.8421;
        var s = 20.4894;
        var h = 1;

        // convert to cartesian; lat, lon are radians
        var sf = s * 0.000001;
        var v = a / (Math.sqrt(1 - (e *(Math.sin(lat) * Math.sin(lat)))));
        var x = (v + h) * Math.cos(lat) * Math.cos(lon);
        var y = (v + h) * Math.cos(lat) * Math.sin(lon);
        var z = ((1 - e) * v + h) * Math.sin(lat);
        // transform cartesian
        var xrot = (xr / 3600) * deg2rad;
        var yrot = (yr / 3600) * deg2rad;
        var zrot = (zr / 3600) * deg2rad;
        var hx = x + (x * sf) - (y * zrot) + (z * yrot) + xp;
        var hy = (x * zrot) + y + (y * sf) - (z * xrot) + yp;
        var hz = (-1 * x * yrot) + (y * xrot) + z + (z * sf) + zp;
        // Convert back to lat, lon
        lon = Math.atan(hy / hx);
        var p = Math.sqrt((hx * hx) + (hy * hy));
        lat = Math.atan(hz / (p * (1 - e2)));
        v = a2 / (Math.sqrt(1 - e2 * (Math.sin(lat) * Math.sin(lat))));
        var errvalue = 1.0;
        var lat0 = 0;
        while (errvalue > 0.001)
        {
          lat0 = Math.atan((hz + e2 * v * Math.sin(lat)) / p);
          errvalue = abs(lat0 - lat);
          lat = lat0;
        }
        h = p / Math.cos(lat) - v;
        lat = lat* rad2deg;
        lon = lon * rad2deg;

        return [lat,lon];
    }

    //  http://www.dorcus.co.uk/carabus/ll_ngr.html
    // Convert lat / lon to eastings and northings
    //   - Input: 2 element array: [lat,lon]
    //   - Return: 2 element array: [east,north]
    function OSBG36_latlon_to_numeric_gridref(OSGB36_coords)
    {
        var lat = OSGB36_coords[0];
        var lon = OSGB36_coords[1];

        var phi = lat * deg2rad;      // convert latitude to radians
        var lam = lon * deg2rad;   // convert longitude to radians
        var a = 6377563.396;       // OSGB semi-major axis
        var b = 6356256.91;        // OSGB semi-minor axis
        var e0 = 400000;           // OSGB easting of false origin
        var n0 = -100000;          // OSGB northing of false origin
        var f0 = 0.9996012717;     // OSGB scale factor on central meridian
        var e2 = 0.0066705397616;  // OSGB eccentricity squared
        var lam0 = -0.034906585039886591;  // OSGB false east
        var phi0 = 0.85521133347722145;    // OSGB false north
        var af0 = a * f0;
        var bf0 = b * f0;
        // easting
        var slat2 = Math.sin(phi) * Math.sin(phi);
        var nu = af0 / (Math.sqrt(1 - (e2 * (slat2))));
        var rho = (nu * (1 - e2)) / (1 - (e2 * slat2));
        var eta2 = (nu / rho) - 1;
        var p = lam - lam0;
        var IV = nu * Math.cos(phi);
        var clat3 = Math.pow(Math.cos(phi),3);
        var tlat2 = Math.tan(phi) * Math.tan(phi);
        var V = (nu / 6) * clat3 * ((nu / rho) - tlat2);
        var clat5 = Math.pow(Math.cos(phi), 5);
        var tlat4 = Math.pow(Math.tan(phi), 4);
        var VI = (nu / 120) * clat5 * ((5 - (18 * tlat2)) + tlat4 + (14 * eta2) - (58 * tlat2 * eta2));
        var east = floor(e0 + (p * IV) + (Math.pow(p, 3) * V) + (Math.pow(p, 5) * VI));
        // northing
        var n = (af0 - bf0) / (af0 + bf0);
        var M = Marc(bf0, n, phi0, phi);
        var I = M + (n0);
        var II = (nu / 2) * Math.sin(phi) * Math.cos(phi);
        var III = ((nu / 24) * Math.sin(phi) * Math.pow(Math.cos(phi), 3)) * (5 - Math.pow(Math.tan(phi), 2) + (9 * eta2));
        var IIIA = ((nu / 720) * Math.sin(phi) * clat5) * (61 - (58 * tlat2) + tlat4);
        var north = floor(I + ((p * p) * II) + (Math.pow(p, 4) * III) + (Math.pow(p, 6) * IIIA));
    //System.println("to numeric grid "  + east.toString() + "," + north.toString() );
        return [east,north];

    }

    function Marc(bf0, n, phi0, phi)
    {
        var Marc = bf0 * (((1 + n + ((5 / 4) * (n * n)) + ((5 / 4) * (n * n * n))) * (phi - phi0))
         - (((3 * n) + (3 * (n * n)) + ((21 / 8) * (n * n * n))) * (Math.sin(phi - phi0)) * (Math.cos(phi + phi0)))
         + ((((15 / 8) * (n * n)) + ((15 / 8) * (n * n * n))) * (Math.sin(2 * (phi - phi0))) * (Math.cos(2 * (phi + phi0))))
         - (((35 / 24) * (n * n * n)) * (Math.sin(3 * (phi - phi0))) * (Math.cos(3 * (phi + phi0)))));
        return(Marc);
    }

    function floor(x)
    {
          return x.toLong();
    }

    function abs(n)
    {
      return n >=0 ? n : -n;
    }

}
