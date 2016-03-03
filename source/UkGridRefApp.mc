using Toybox.Application as App;
using Toybox.System;

class UkGridRefApp extends App.AppBase {

    var view = null;

    function onSettingsChanged() {
      if (view != null) {
        view.updateSettings = true;
      }
    }
    //! onStart() is called on application start up

    function onStart() {
// http://www.movable-type.co.uk/scripts/latlong-gridref.html
//        test(52.657689,1.7178690,"TG5153413151");  //  651534,313151 | TG 51534 13151 | OSGB36:  52.657277°N 001.719732°E
  //      test(51.063236,-1.3306010,"SU4700529535");  // SU 47005 29535  | 447005,129535  | OSGB36:  51.062691°N    001.329151°W

    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        view = new UkGridRefView() ;
        return [ view ];
    }

//    function test(lat,lon,t,e,n)
//    {
//      var gridref = new UkGridRefUtils(lat, lon,10);
//      System.println("=========================================================");
//      System.println("Results for: " + lat + "," + lon);
//      System.println("  Northings,Eastings: " + gridref.north + "," + gridref.east);
//      System.println("Grid Ref: " +  gridref.toString);
//      System.println("Expected: " +  t + e + n);
//    }
}
