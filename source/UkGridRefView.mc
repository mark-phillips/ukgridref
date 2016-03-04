using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Lang as Lang;
using Toybox.Activity;

class UkGridRefView extends Ui.SimpleDataField {
  var current_second = 0;
  var current_screen = 0;
  var MAX_SCREENS = 4; // GridRef, Eastings, Northings, Heading
  var current_screen_display_time = new [MAX_SCREENS];
  var SHOW_GRID_REF = true;
  var SHOW_EASTINGS_NORTHINGS = true;
  var SHOW_HEADING = false;
  var HEADING_DISPLAY_TIME = 3;
  var GRID_REF_PRECISION = 6;
  var updateSettings = false;


    //! Set the label of the data field here.
    function initialize() {
       label = "GridRef";
       RetrieveSettings() ;
    }

    // Pick up settings changes
    function RetrieveSettings() {
      GRID_REF_PRECISION = Application.getApp().getProperty("GRID_REF_PRECISION");
      current_screen_display_time[0] = Application.getApp().getProperty("GRID_REF_DISPLAY_TIME");
      SHOW_EASTINGS_NORTHINGS = Application.getApp().getProperty("SHOW_EASTINGS_NORTHINGS");
      current_screen_display_time[1] = Application.getApp().getProperty("EASTINGS_NORTHINGS_DISPLAY_TIME");
      current_screen_display_time[2] = Application.getApp().getProperty("EASTINGS_NORTHINGS_DISPLAY_TIME");
      SHOW_HEADING = Application.getApp().getProperty("SHOW_HEADING");
      current_screen_display_time[3] = Application.getApp().getProperty("HEADING_DISPLAY_TIME");

//System.println("GRID_REF_PRECISION " + GRID_REF_PRECISION );
//System.println("current_screen_display_time[0] " + current_screen_display_time[0] );
//System.println("SHOW_EASTINGS_NORTHINGS " + SHOW_EASTINGS_NORTHINGS );
//System.println("current_screen_display_time[1] " + current_screen_display_time[1] );
//System.println("current_screen_display_time[2] " + current_screen_display_time[2] );
//System.println("SHOW_HEADING " + SHOW_HEADING );
//System.println("current_screen_display_time[3] " + current_screen_display_time[3] );
    }


    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
      var content = "Unknown!";
      if (updateSettings == true) {
        RetrieveSettings() ;
        updateSettings = false;
      }

      var displayed_content = false;
      do {
        //
          //  Render accuracy if GPS is not "good"
        if (info has :currentLocationAccuracy && info.currentLocationAccuracy < 4
            &&  current_second <= 1
            && current_screen == 0 )
        {
          content = "GPS:" + render_accuracy_screen(info);
          displayed_content = true;
        }
        //
        // Render 6 or 8 figure grid ref
        //  gr[0] - Grid square
        //  gr[1] - Easting
        //  gr[2] - Northing
        //  gr[3] - Grid ref valid?
        else {
          if ( 0 == current_screen   ) {
            var gr = null;
            if (8 == GRID_REF_PRECISION ) {
              gr = create_gridref_util(info,8).getGR();
            }
            else {
              gr = create_gridref_util(info,6).getGR();
            }
            content = gr[0];
            displayed_content = true;
            if (gr[3] == true) {
              content += " " + gr[1] + " " + gr[2];
            }
          }
          // Show Easting & heading
          if (current_screen == 1  ) {
            if (SHOW_EASTINGS_NORTHINGS == true ){
              var gr = create_gridref_util(info,8).getGR();
              content =  "E" + gr[1] + " (" + getHeading(info)[0] +")";
              displayed_content = true;
            }
            else  { // move to next screen
              current_screen += 1;
            }
          }
          //
          // Show Northing & heading
          if (current_screen == 2  ) {
            if (SHOW_EASTINGS_NORTHINGS == true ){
              var gr = create_gridref_util(info,8).getGR();
              content =  "N" + gr[2] + " (" + getHeading(info)[0] +")";
              displayed_content = true;
            }
            else  { // move to next screen
              current_screen += 1;
            }
          }
          //
          // Show Heading
          if (current_screen == 3  ) {
            if (SHOW_HEADING == true ){
               var heading = getHeading(info);
               content =  heading[1] + " " + heading[0];
               displayed_content = true;
             }
             else  { // move to next screen
               current_screen += 1;
             }
           }
        }
        //
        //  Increment and wrap current second
//System.println("current_screen " + current_screen +" current_second " + current_second);

        if (current_screen >= MAX_SCREENS or current_second >= current_screen_display_time[current_screen]-1 ) {
          current_second = 0;
          current_screen += 1;
          if (current_screen >= MAX_SCREENS) {
            current_screen = 0;
          }
        }
        else {
          current_second += 1;
        }
      } while (false == displayed_content); // if we didn't find anything to display, loop
      return content;
    }

    function render_accuracy_screen(info)
    {
      var accuracy = "No fix";

      if (info has :currentLocationAccuracy) {
        if (info.currentLocationAccuracy == 0) {
           accuracy = "No fix";
        }
        else if (info.currentLocationAccuracy == 1) {
           accuracy = "Old Fix";
        }
        else if (info.currentLocationAccuracy == 2)  {
           accuracy = "Poor";
        }
        else if (info.currentLocationAccuracy == 3)  {
           accuracy = "Usable";
        }
        else if (info.currentLocationAccuracy == 4)  {
           accuracy = "Good";
        }
        else  {
            accuracy = info.currentLocationAccuracy.toString();
        }
      }
    return  accuracy ;
  }

  //
  //  Calculate heading
    function getHeading(info)
    {
      var heading = "??";
      var  degree_string = "???";
      var  index = 0;
//      var directions = [ "N", "NE", "E", "SE", "S", "SW", "W", "NW", "N" ];
      var directions = [ "N", "NNE","NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW","SW",  "WSW", "W", "WNW","NW",  "NNW", "N" ];
      if (info has :currentHeading && info.currentHeading != null )
      {
        heading = info.currentHeading;
        var degree_int = 0;
        var degrees = info.currentHeading * 180 / Math.PI;
        if (degrees  < 0) {
          degrees  += 360.0;
        }

        if (degrees instanceof Toybox.Lang.Float) {
          degree_string = degrees.toNumber().format("%03u");
        } else {
          degree_string = degrees.format("%03u");
        }
        index = ((degrees + 12) / 22.5).toNumber();
//      System.println( index +" " +   degree_string + " " + directions[index] );
      }
      return [directions[index], degree_string];
    }

    function create_gridref_util(info,precision)
    {
       var location = null;
        if (info has :currentLocation && info.currentLocation != null )
        {
          if (info.currentLocation has :toDegrees )
          {
            var degrees = info.currentLocation.toDegrees();
            if (degrees != null and degrees[0] != null and  degrees.size() == 2)
            {
              location =  new UkGridRefUtils(degrees[0], degrees[1], precision );
            }
          }
        }
        if (location == null) {
          location = new UkGridRefUtils(null, null, 6 );
        }
       return location;
    }
}

