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

    function onStart(state) {

    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        view = new GridRefView("OSGridRef",1) ;
        return [ view ];
    }
}
