using Toybox.Time as Time;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;
//using Toybox.WatchUi as Ui;
using Toybox.Activity as Act;
using Toybox.Math as Math;
using Toybox.Graphics as Gfx;
//using Toybox.System as Sys;


module extras{

 	function drawSunMarkers(dc) {
	// Draw Sunset / sunrise markers -------------------------------------------------------------------------
        
        var alphaSunrise = 0;
        var alphaSunset = 0;
	   	var sc = new SunCalc();
		var lat;
		var lon;
		var info = Act.getActivityInfo();	
		var loc = info.currentLocation;

		if (loc == null)
		{
			lat = App.getApp().getProperty(LAT);
			lon = App.getApp().getProperty(LON);
		} 
		else
		{
			lat = loc.toDegrees()[0] * Math.PI / 180.0;
			App.getApp().setProperty(LAT, lat);
			lon = loc.toDegrees()[1] * Math.PI / 180.0;
			App.getApp().setProperty(LON, lon);
		}

//		lat = 52.375892 * Math.PI / 180.0;
//		lon = 9.732010 * Math.PI / 180.0;

		if(lat != null && lon != null)
		{
			var now = new Time.Moment(Time.now().value());			
			var sunrise_moment = sc.calculate(now, lat.toDouble(), lon.toDouble(), SUNRISE);
			var sunset_moment = sc.calculate(now, lat.toDouble(), lon.toDouble(), SUNSET);
			
			var sunriseTinfo = Time.Gregorian.info(new Time.Moment(sunrise_moment.value() + 30), Time.FORMAT_SHORT);
			var sunsetTinfo = Time.Gregorian.info(new Time.Moment(sunset_moment.value() + 30), Time.FORMAT_SHORT);
   	       
    		alphaSunrise = Math.PI/6*(1.0*sunriseTinfo.hour+sunriseTinfo.min/60.0);
    		alphaSunset = Math.PI/6*(1.0*sunsetTinfo.hour+sunsetTinfo.min/60.0);
      
        	var r1;      	
        	var outerRad = 0;
        	var center_x = dc.getWidth() / 2;
        	var center_y = dc.getHeight() / 2;
     
			r1 = dc.getWidth()/2 - outerRad; //outside
     
			dc.setColor(App.getApp().getProperty("QuarterNumbersColor"), Gfx.COLOR_TRANSPARENT);
			
			dc.setPenWidth(1);
			dc.drawCircle(center_x+(r1-15)*Math.sin(alphaSunrise),center_y-(r1-15)*Math.cos(alphaSunrise),6);			
			dc.drawCircle(center_x+(r1-15)*Math.sin(alphaSunset),center_y-(r1-15)*Math.cos(alphaSunset),6);			
			
			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT); //Haard coding to a different yellow. Don't think it'll affect 14-color watches...	
			dc.fillCircle(center_x+(r1-15)*Math.sin(alphaSunrise),center_y-(r1-15)*Math.cos(alphaSunrise),5);	
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
			dc.fillCircle(center_x+(r1-15)*Math.sin(alphaSunset),center_y-(r1-15)*Math.cos(alphaSunset),5);	
		}			
	}
	




}