using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Lang as Lang;
using Toybox.Activity;

class UkGridRefView extends Ui.SimpleDataField {
  var current_second = 0;

    //! Set the label of the data field here.
    function initialize() {
       label = "GridRef";
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
        var content = "Unknown!";
        var MAX_SECOND = 9 ;
//System.println("sec: " + current_second );

        //
        //  Ten second display cycle - first render accuracy
        if (current_second <= 1) {
          content = "(" + getHeading(info) + ") " + render_accuracy_screen(info) ;
        }
        //
        // Render 6 figure grid ref
        else if (current_second <=4 ) {
            content = create_gridref_util(info,6).toString();
        }
        // Flash heading
        else if (current_second <=6 ) {
            content = "Hdg: " + getHeading(info);
        }
        //
        // Render 6 figure grid ref
        else if (current_second <=MAX_SECOND   ) {
            content = create_gridref_util(info,6).toString();
        }
        //
        //  Increment and wrap current second
        if (current_second == MAX_SECOND ) {
          current_second = 0;
        }
        else {
          current_second += 1;
        }
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
      var heading = "--";
      if (info has :currentHeading && info.currentHeading != null )
      {
        heading = info.currentHeading;
        var degrees = info.currentHeading * 180 / Math.PI;
        if (degrees  < 0) {
          degrees  += 360.0;
        }
        if (degrees <= 22.5) {
          heading = "N";
        } else if (degrees < 67.5) {
          heading = "NE";
        } else if (degrees <= 112.5) {
          heading = "E";
        } else if (degrees < 157.5) {
            heading = "SE";
        } else if (degrees <= 202.5) {
          heading = "S";
        } else if (degrees < 247.5) {
          heading = "SW";
        } else if (degrees <= 292.5) {
          heading = "W";
        } else if (degrees < 337.5) {
          heading = "NW";
        } else {
          heading = "N";
        }
      }
      return heading;
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

