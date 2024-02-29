using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.Activity as Act;
using Toybox.ActivityMonitor as ActMonitor;
using Toybox.Sensor as Snsr;

var partialUpdatesAllowed = false;

enum
{
    LAT,
    LON
}


class BatHistView extends Ui.WatchFace{
	    
	    //Positions for Displays + Text
	    var ULBGx, ULBGy, ULBGwidth;
	    var ULTEXTx, ULTEXTy;
	    var ULINFOx, ULINFOy;  
	    
	  	var LLBGx, LLBGy, LLBGwidth;
	    var LLTEXTx, LLTEXTy;
	    var LLINFOx, LLINFOy;
	    var labelText;
	  	var labelInfoText;  
	  	
	  	var infoLeft;
		var infoRight;
	    
	    var isAwake;
	    
	    var offscreenBuffer;
	    var fullScreenRefresh;
	    
	    var screenShape;
	    var fontLabel;
	    var fontIcons;
	    
	    var clockTime;
	    
	  	var width;
	    var height;  
	  	// the x coordinate for the center
	    var center_x;
	    // the y coordinate for the center
	    var center_y;      
	    
	   
		var lastLoc;
		
	
		var moonx, moony, moonwidth;
		
		var BatteryIcon="0";
		var AlarmIcon="1";
		var PhoneIcon="2";
		var MoonIcon="3";
		var MessageIcon="4";
		var ConnectedPhoneIcon="C";
		var DisconnectedPhoneIcon="D";
		var bat_hist;
		var sec_hands_form;
		var sec_hands_color1;
		var sec_hands_color2;	
		
    function initialize() {
        WatchFace.initialize();        
	    fontLabel = Ui.loadResource(Rez.Fonts.id_font_label);
	    fontIcons = Ui.loadResource(Rez.Fonts.id_font_icons);
        screenShape = Sys.getDeviceSettings().screenShape;                  
        Sys.println("Screenshape = " + screenShape);  
		isAwake = true;
        
        fullScreenRefresh = true;
        partialUpdatesAllowed = ((Toybox.Graphics has :BufferedBitmap) && (Toybox.WatchUi.WatchFace has :onPartialUpdate));
               
    }//end of initialize()
   
    
    function onLayout(dc) { 
        width = dc.getWidth();
        height = dc.getHeight();
        center_x = dc.getWidth() / 2;
        center_y = dc.getHeight() / 2;
        
		if (width == 218 && height == 218) {
			Sys.println("device:" + "Fenix3 218");
			ULBGx = 38;
		   	ULBGy = 53;
		   	ULBGwidth = 142;
		    
		   	ULTEXTx = 109;
		   	ULTEXTy = 55;
		    
		   	ULINFOx = 175;
		   	ULINFOy = 50;   
		    
		   	LLBGx = 42;
		   	LLBGy = 137;
		   	LLBGwidth = 42;
		    
		   	LLTEXTx = 65;
		   	LLTEXTy = 135;
		    
		   	LLINFOx = 175;
		   	LLINFOy = 130; 
		    
		   	moonx = 130;
		   	moony = 130;
		   	moonwidth = 40; 		
		}
		if (width == 240 && height == 240) {
			Sys.println("device:" + "Fenix5 240");
			ULBGx = 45;
		   	ULBGy = 57;
		   	ULBGwidth = 150;
		    
		   	ULTEXTx = 120;
		   	ULTEXTy = 59;
		    
		   	ULINFOx = 188;
		   	ULINFOy = 57;   
		    
		   	LLBGx = 75;
		   	LLBGy = 147;
		   	LLBGwidth = 90;
		    
		   	LLTEXTx = 120;
		   	LLTEXTy = 149;
		    
		   	LLINFOx = 188;
		   	LLINFOy = 148; 
		    
		   	moonx = 155;
		   	moony = 140;
		   	moonwidth = 40; 		
		}
		if (width == 260 && height == 260) {
			Sys.println("device:" + "Fr255 260");
			ULBGx = 45;
		   	ULBGy = 57;
		   	ULBGwidth = 150;
		    
		   	ULTEXTx = 120;
		   	ULTEXTy = 59;
		    
		   	ULINFOx = 188;
		   	ULINFOy = 57;   
		    
		   	LLBGx = 75;
		   	LLBGy = 147;
		   	LLBGwidth = 90;
		    
		   	LLTEXTx = 70;
		   	LLTEXTy = 160;
		    
		   	LLINFOx = 188;
		   	LLINFOy = 148; 
		    
		   	moonx = 180;
		   	moony = 150;
		   	moonwidth = 40; 		
		}
		if (width == 215 && height == 180) {
			Sys.println("device:" + "Semiround");
			ULBGx = 35;
		   	ULBGy = 33;
		   	ULBGwidth = 145;
		    
		   	ULTEXTx = 107.5;
		   	ULTEXTy = 35;
		    
		   	ULINFOx = 174;
		   	ULINFOy = 34;   
		    
		   	LLBGx = 35;
		   	LLBGy = 110;
		   	LLBGwidth = 145;
		    
		   	LLTEXTx = 107.5;
		   	LLTEXTy = 112;
		    
		   	LLINFOx = 174;
		   	LLINFOy = 111; 
		    
		   	moonx = 165;
		   	moony = 71;
		   	moonwidth = 36; 		
		} 
		
	 // If this device supports BufferedBitmap, allocate the buffers we use for drawing
        if((Toybox.Graphics has :BufferedBitmap) && (Ui.WatchFace has :onPartialUpdate)) {
            // Allocate a full screen size buffer with a palette of only a few colors to draw
            // the background image of the watchface.  This is used to facilitate blanking
            // the second hand during partial updates of the display

			var options = {
                :width=>dc.getWidth(),
                :height=>dc.getHeight(),
                :palette=> [
                 	//App.getApp().getProperty("BackgroundColor"),
                 	//App.getApp().getProperty("MinutesColor"),
                 	//App.getApp().getProperty("QuarterNumbersColor"),
                    Graphics.COLOR_DK_GREEN,
                    Graphics.COLOR_GREEN,
                    Graphics.COLOR_DK_BLUE,
                    Graphics.COLOR_BLUE,
                    Graphics.COLOR_DK_RED,
                    Graphics.COLOR_RED,
                    Graphics.COLOR_ORANGE,
                    0xFFFF00,
                    //Graphics.COLOR_YELLOW,
                    Graphics.COLOR_PURPLE,
                    Graphics.COLOR_PINK,                   
              		Graphics.COLOR_LT_GRAY,
              		Graphics.COLOR_DK_GRAY,
              		Graphics.COLOR_BLACK,
              		Graphics.COLOR_WHITE,
              		App.getApp().getProperty("BackgroundColorR")+App.getApp().getProperty("BackgroundColorG")+App.getApp().getProperty("BackgroundColorB")
                ]
                
            };
			if (Gfx has :createBufferedBitmap) {
        		offscreenBuffer = Gfx.createBufferedBitmap(options);
    		} else {
            	offscreenBuffer = new Gfx.BufferedBitmap(options);
			}
            // Allocate a buffer tall enough to draw the date into the full width of the
            // screen. This buffer is also used for blanking the second hand. This full
            // color buffer is needed because anti-aliased fonts cannot be drawn into
            // a buffer with a reduced color palette
          //  dateBuffer = new Graphics.BufferedBitmap({
          //      :width=>dc.getWidth(),
          //      :height=>Graphics.getFontHeight(Graphics.FONT_MEDIUM)
          //  });
        } else {
            offscreenBuffer = null;
        }

		bat_hist = new BatHist(center_x, center_y / 2);
        
    } // onLayout(dc)

   

    // Draw the hash mark symbols on the watch-------------------------------------------------------
    function drawHashMarks(dc) {
        	var r1, r2;

			if (App.getApp().getProperty("MinutesColor") != 0x000001) {
	        	//alle 1 minutes
	            dc.setPenWidth(3);
	            dc.setColor(App.getApp().getProperty("MinutesColor"), Gfx.COLOR_TRANSPARENT);
	           	r1 = width/2 -5; //inside
				r2 = width/2 +1; //outside. Yeah, I know that's making the radius longer than the screen, but it makes the tic marks render nicer
	           	for (var alpha = Math.PI / 30; alpha <= 2 * Math.PI ; alpha += (Math.PI / 6)) { //jede Minute 
	           		for (var beta = 0; beta <= (Math.PI / 10); beta += (Math.PI/30)) {          	 			
						dc.drawLine(center_x+r1*Math.sin(alpha+beta),center_y-r1*Math.cos(alpha+beta), center_x+r2*Math.sin(alpha+beta),center_y-r2*Math.cos(alpha+beta)); 
					}
	     		}
			}        
        	//alle 5 minutes
            dc.setPenWidth(4);
            dc.setColor(App.getApp().getProperty("QuarterNumbersColor"), Gfx.COLOR_TRANSPARENT);
           	r1 = width/2 - (5 * App.getApp().getProperty("markslenth"));
			r2 = width/2 - 4;
			for (var alpha = Math.PI / 6; alpha <= 11 * Math.PI / 6; alpha += (Math.PI / 3)) { //jede 5. Minute  			
				dc.drawLine(center_x+r1*Math.sin(alpha),center_y-r1*Math.cos(alpha), center_x+r2*Math.sin(alpha),center_y-r2*Math.cos(alpha)); 
				alpha += Math.PI / 6;  
				dc.drawLine(center_x+r1*Math.sin(alpha),center_y-r1*Math.cos(alpha), center_x+r2*Math.sin(alpha),center_y-r2*Math.cos(alpha));    	
     		}      
 
    }
    
    function drawQuarterHashmarks(dc){          
      //12, 3, 6, 9
      var NbrFont = (App.getApp().getProperty("Numbers"));
      
      
      
       if ( NbrFont == 0 || NbrFont == 1) { //no number	  		
        	var r1, r2,  thicknes;      	
        	var outerRad = 0;
        	var lenth=20;
        	if (screenShape == 1) {  //semi round 
        		lenth = 20;
        	}
        	if (screenShape == 2) {  //semi round 
        		lenth = 30;
        	}	
        	
        	var thick = 5;
        	thicknes = thick * 0.02;
        	
        	//when moon then only three marks
        	var nurdrei = 0;
        	var alphaMax = 4;
        	var MoonEnable = (App.getApp().getProperty("MoonEnable"));
				if (MoonEnable && NbrFont == 0) {
        			nurdrei = (Math.PI / 2) ;
        			alphaMax = 4;
        		}
        		if (MoonEnable && NbrFont == 1) {
        			nurdrei = (Math.PI / 2) ;
        			alphaMax = 3;
        		}
        		if (MoonEnable == false && NbrFont == 0) {
        			nurdrei = 0;
        			alphaMax = 4;
        		}
        		if (MoonEnable == false && NbrFont == 1) {
        			nurdrei = 0 ;
        			alphaMax = 3;
        		}
        		      	
           	for (var alpha = (Math.PI / 2) + nurdrei ; alpha <= alphaMax * Math.PI / 2; alpha += (Math.PI / 2)) { //jede 15. Minute    
				r1 = (width/2 + 3) - outerRad; //outside
				r2 = r1 -lenth; //inside			
							
			var marks = [[center_x+r1*Math.sin(alpha-thicknes),center_y-r1*Math.cos(alpha-thicknes)],
						[center_x+r2*Math.sin(alpha-thicknes),center_y-r2*Math.cos(alpha-thicknes)],
						[center_x+r2*Math.sin(alpha+thicknes),center_y-r2*Math.cos(alpha+thicknes)],
						[center_x+r1*Math.sin(alpha+thicknes),center_y-r1*Math.cos(alpha+thicknes)]   ];
			
			dc.setColor(App.getApp().getProperty("QuarterNumbersColor"), Gfx.COLOR_TRANSPARENT);		
			dc.fillPolygon(marks);
			
			dc.setPenWidth(1);
        	dc.setColor(App.getApp().getProperty("BackgroundColor"), Gfx.COLOR_TRANSPARENT);
        	dc.drawLine(center_x+r2*Math.sin(alpha),center_y-r2*Math.cos(alpha), center_x+r1*Math.sin(alpha),center_y-r1*Math.cos(alpha));
			
			//Sys.println(alpha + " - " + (2 * Math.PI / 2));   		
			}
		}	
		else {	
	        var r1 = width/2 -5; //inside
			var r2 = width/2 ; //outside
		   	dc.setPenWidth(8);       
            dc.setColor(App.getApp().getProperty("QuarterNumbersColor"), Gfx.COLOR_TRANSPARENT);
            for (var alpha = Math.PI / 2; alpha <= 13 * Math.PI / 2; alpha += (Math.PI / 2)) {
				dc.drawLine(center_x+r1*Math.sin(alpha),center_y-r1*Math.cos(alpha), center_x+r2*Math.sin(alpha),center_y-r2*Math.cos(alpha));                
             }
         }
    } 

	function drawGrid(dc) {
        dc.setPenWidth(1);
		dc.setColor(0x303030, Graphics.COLOR_TRANSPARENT);
		var spacing = 10;
		for (var x = spacing; x < width; x+=spacing) {
			dc.drawLine(x,0,x,height - 1);

		}
		for (var y = spacing; y < height; y+=spacing) {
			dc.drawLine(0,y,width - 1,y);

		}
 

	}
    function drawGauges(dc) {
        dc.setPenWidth(6);
		var battery = Toybox.System.getSystemStats().battery / 100;       

		// Right gauge
        var start = 360 / 12 * -2;
        var full_length = 360 / 12 * 4;
        var dir = Gfx.ARC_CLOCKWISE;
		for (var i = 0; i < 2; i++) {
            dc.setColor(Graphics.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
			dc.drawArc(width/2, width/2, width/2-3, dir, start + battery * full_length, start);
            dc.setColor(Graphics.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
			dc.drawArc(width/2, width/2, width/2-3, dir, start + full_length, start + battery * full_length);
			// Left gauge
            start = 360 / 12 * 8;
            full_length = 360 / 12 * -4;
            dir = Gfx.ARC_COUNTER_CLOCKWISE;
		}
    }
 
	function drawAltitude() {
			
			var unknownaltitude = true;
			var actaltitude = 0;
			var actInfo;
			var metric = Sys.getDeviceSettings().elevationUnits == Sys.UNIT_METRIC;
			labelInfoText = "m";
						
			actInfo = Act.getActivityInfo();
			if (actInfo != null) {
			
				if (metric) {				
				labelInfoText = "m";
				actaltitude = actInfo.altitude;
				} else {
				labelInfoText = "ft";
				actaltitude = actInfo.altitude  * 3.28084;
				}
			
			
				if (actaltitude != null) {
					unknownaltitude = false;
				} 				
			}			
							
			if (unknownaltitude) {
				labelText = "unknown";
			} else {
				labelText = Lang.format("$1$", [actaltitude.toLong()]);				
			}
			
			infoLeft = labelText;
       		//dc.drawText(width / 2, (height / 10 * 6.9), fontDigital, altitudeStr, Gfx.TEXT_JUSTIFY_CENTER);
        }
	
	
function drawBattery(dc) {
	// Draw battery -------------------------------------------------------------------------
		
		var Battery = Toybox.System.getSystemStats().battery;       
        
        var alpha, hand;
        alpha = 0; 
        
        if (screenShape == 1) {  //round 
        alpha = 2*Math.PI/100*(Battery); 
		}		
		if (screenShape == 2) {  //semi round
        alpha = (Math.PI-1)/100*(Battery)+Math.PI+0.5;
		}
        if (Battery >= 25) {
        dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
        }
        if (Battery < 25) {
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
		if (Battery >= 50) {
        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        }
						
			var r1, r2;      	
        	var outerRad = 0;
        	var lenth = 15;
     
			r1 = width/2 - outerRad; //outside
			r2 = r1 -lenth; ////L�nge des Bat-Zeigers
										
			//if (!App.getApp().getProperty("UseIcons")){
				hand =     [[center_x+r1*Math.sin(alpha+0.1),center_y-r1*Math.cos(alpha+0.1)],
						[center_x+r2*Math.sin(alpha),center_y-r2*Math.cos(alpha)],
						[center_x+r1*Math.sin(alpha-0.1),center_y-r1*Math.cos(alpha-0.1)]   ];
				dc.fillPolygon(hand);
				dc.setColor(App.getApp().getProperty("QuarterNumbersColor"), Gfx.COLOR_TRANSPARENT);
				dc.setPenWidth(1);
				var n;
				for (n=0; n<2; n++) {
					dc.drawLine(hand[n][0], hand[n][1], hand[n+1][0], hand[n+1][1]);
				}
				dc.drawLine(hand[n][0], hand[n][1], hand[0][0], hand[0][1]);			
			//} else {
				//Draw a battery icon that rotates around the dial?			
											

	}
	
	
	//StepGoal progress-------------------------------
 	function drawStepGoal(dc) {
              
        var actsteps = 0;
        var stepGoal = 0;		
		
		stepGoal = ActMonitor.getInfo().stepGoal;
		actsteps = ActMonitor.getInfo().steps;
		var stepPercent = 100 * actsteps / stepGoal;
        
        //dc.drawText(width / 2, (height / 4 * 3), fontDigital, stepGoal, Gfx.TEXT_JUSTIFY_CENTER);
        //dc.drawText(width / 2, (height / 5), fontDigital, stepPercent, Gfx.TEXT_JUSTIFY_CENTER);
       
       	if (stepPercent >= 100) {
       		stepPercent = 100;
       	} 
       	
       	if (stepPercent > 95) {
       		dc.setColor(Gfx.COLOR_PURPLE, Gfx.COLOR_TRANSPARENT);
       	}
       	if (stepPercent <= 95) {
       		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
       	}
       	if (stepPercent < 70 ) {
       		dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
       	}
       	if (stepPercent < 29) {
       		dc.setColor(Gfx.COLOR_ORANGE , Gfx.COLOR_TRANSPARENT);
       	}
       	if (stepPercent < 5) {
       		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
       	}
       	
       	    
              
        var alpha, hand;
        alpha = 0; 
        
        if (screenShape == 1) {  //1=round 
        alpha = 2*Math.PI/100*(stepPercent);
		}		
		if (screenShape == 2) {  //2=semi round
        //alpha = (Math.PI-1)/100*(Battery)+Math.PI+0.5;
        alpha = (Math.PI-0.5)-(Math.PI-1)/100*(stepPercent);
		}
         
	
			var r1, r2;      	
        	var outerRad = 0;
        	var lenth = 15;
     
			r1 = width/2 - outerRad; //outside
			r2 = r1 -lenth; ////L�nge des Step-Zeigers
										
			hand =     [[center_x+r2*Math.sin(alpha+0.1),center_y-r2*Math.cos(alpha+0.1)],
						[center_x+r1*Math.sin(alpha),center_y-r1*Math.cos(alpha)],
						[center_x+r2*Math.sin(alpha-0.1),center_y-r2*Math.cos(alpha-0.1)]   ];					
		
       if (stepPercent < 100) {       
					
			dc.fillPolygon(hand);			
			dc.setColor(App.getApp().getProperty("QuarterNumbersColor"), Gfx.COLOR_TRANSPARENT);
	        dc.setPenWidth(1);
	        var n;
			for (n=0; n<2; n++) {
				dc.drawLine(hand[n][0], hand[n][1], hand[n+1][0], hand[n+1][1]);
			}
			dc.drawLine(hand[n][0], hand[n][1], hand[0][0], hand[0][1]);
		}
		
 	}


	function momentToString(moment) {
		if (moment == null) {
			return "--:--";
		}

   		var tinfo = Time.Gregorian.info(new Time.Moment(moment.value() + 30), Time.FORMAT_SHORT);
		var text;
		if (Sys.getDeviceSettings().is24Hour) {
			text = tinfo.hour.format("%02d") + ":" + tinfo.min.format("%02d");
		} else {
			var hour = tinfo.hour % 12;
			if (hour == 0) {
				hour = 12;
			}
			text = hour.format("%02d") + ":" + tinfo.min.format("%02d");			
		}
		return text;
	}
 	

    function buildSunsetStr()
    {
		var sc = new SunCalc();
		var lat;
		var lon;		
		var loc = Act.getActivityInfo().currentLocation;

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
			var sunrise = momentToString(sunrise_moment);
			var sunset = momentToString(sunset_moment);		

    		labelText =  sunrise + "  " + sunset;
    		   		
    		infoLeft = sunrise;
			infoRight = sunset;	
				
		}else{
	    	labelText = Ui.loadResource(Rez.Strings.none);
	    	}
		
	}

	//draw stepHistory-Graph-----------------------------------------------------------------------------------	
	function drawStepGraph(dc,stepGraphposX, stepGraphposY, stepInfoX, stepInfoY) {
		var activityHistory = ActMonitor.getHistory();
	  	var histDays=activityHistory.size();
	  	//Sys.println("stepHistoryGraph histDays: " + histDays);
	  		  	
	  	var maxheight = 26.0;	  	
	  	var stepHistory=0;
	  	var maxValue; 
	  	var graphheight; 
	  	//Sys.println("graphheight : " + graphheight);
	  	
	  	var graphposX = stepGraphposX;
	  	var graphposY = stepGraphposY + 4;
	  	
	  	dc.setColor((App.getApp().getProperty("ForegroundColor")), Gfx.COLOR_TRANSPARENT);
	  	dc.setPenWidth(1);
	  	//first draw empty graph---------------------------------------------------------
	  	for(var i=0;i<7;i++) {	 
	  		//Sys.println("empty graph i : " + i); 	
	  		//dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
	  		dc.drawRectangle(graphposX, graphposY, 9, maxheight);
	        graphposX = graphposX - 11;	        
	  	}//--------------------------------------------------------------------------
	  		  	
	  if (histDays > 0) {	  	
	  		graphposX = stepGraphposX;
	  		
		  	for(var i=0;i<histDays;i++) {
		  		maxValue=stepHistory+activityHistory[i].stepGoal;
		  		graphheight = maxheight / maxValue;		  		
		  		stepHistory=stepHistory+activityHistory[i].steps;		  		
		  		graphheight = graphheight * stepHistory;
		  		
		  		if (graphheight > maxheight) {
		  			graphheight = maxheight;
		  		}
		  		
		  		//Sys.println("graphheight " + i + ": " + graphheight);	
		  		dc.fillRectangle(graphposX, graphposY+maxheight-graphheight, 8, graphheight);		  	
		  		dc.setColor((App.getApp().getProperty("ForegroundColor")), Gfx.COLOR_TRANSPARENT);
		  		dc.drawRectangle(graphposX, graphposY, 9, maxheight);
	
		        graphposX = graphposX - 11;
		        stepHistory=0;
		        graphheight = maxheight / maxValue;
		  	}
		  	
		  	//aktual step graph--------------------------------------
		  	maxValue=ActMonitor.getInfo().stepGoal;
	  		graphheight = maxheight / maxValue;
	  		
		  	dc.drawText(stepInfoX, stepInfoY + 17, fontLabel, ActMonitor.getInfo().steps, Gfx.TEXT_JUSTIFY_RIGHT);
	  		graphheight = graphheight * ActMonitor.getInfo().steps;
	  		if (graphheight > maxheight) {
	  			graphheight = maxheight;
	  		}
	  		dc.setColor((App.getApp().getProperty("HandsColor1")), Gfx.COLOR_TRANSPARENT);
	  		dc.fillRectangle(stepGraphposX+11, graphposY+maxheight-graphheight, 9, graphheight);	 
	  		dc.setColor((App.getApp().getProperty("ForegroundColor")), Gfx.COLOR_TRANSPARENT); 	
		  	dc.drawRectangle(stepGraphposX+11, graphposY, 9, maxheight);
	  	}
	  }// end od draw stepHistory-Graph----------------------



	//build string for display in labels-------------------- 
	function setLabel(displayInfo) {
				
			labelText = "";
  			labelInfoText = "";	        
    		     	    	
	 		//Draw date---------------------------------
		   	if (displayInfo == 1) {
		   		date.buildDateString();
		   		labelText = date.dateStr;	  		      
		   		return;
			}	
	
	 	    //Draw Steps --------------------------------------
	      	if (displayInfo == 2) {				   		
		   		labelText = Lang.format("$1$", [ActMonitor.getInfo().steps]);
	  			labelInfoText = Lang.format("$1$", [ActMonitor.getInfo().stepGoal]);   						
	  			return;
			}
			
			//Draw Steps to go --------------------------------------
	      	if (displayInfo == 3) {
	        var actsteps = 0;
	        var stepGoal = 0;
	        var stepstogo = 0;		
			stepGoal = ActMonitor.getInfo().stepGoal;
			actsteps = ActMonitor.getInfo().steps;
			
		        if (actsteps <= stepGoal) {
			        stepstogo = "- " + (stepGoal - actsteps);
			    }
			    if (actsteps > stepGoal) {
			        stepstogo = "+ " + (actsteps - stepGoal);
			    }    			        
			        stepstogo = Lang.format("$1$", [stepstogo]); 			        
		   		labelText = stepstogo;				        			              
		   		return;
			}

	 	    //Draw StepGraph --------------------------------------
	      	if (displayInfo == 4) {				   		
		   		labelText = "";
	  			labelInfoText = Lang.format("$1$", [ActMonitor.getInfo().stepGoal]); 	  						
	  			return;
			}

	    	// Draw Altitude------------------------------
			if (displayInfo == 6) {
				drawAltitude();	
				return;
			 }	
				
			// Draw Calories------------------------------
			if (displayInfo == 7) {	
				var actInfo = ActMonitor.getInfo(); 
		        var actcals = actInfo.calories;		       
		        labelText = Lang.format("$1$", [actcals]);
		        labelInfoText = "kCal";
		        return;
			}
			
			//Draw distance
			if (displayInfo == 8) {
				distance.drawDistance();
				labelText = distance.distStr;
	  			labelInfoText = distance.distUnit;
	  			//Sys.println("Distance");
	  			return;
			}			
			
			//Draw battery
			if (displayInfo == 9) {
				var Battery = Toybox.System.getSystemStats().battery;       
        	    labelText = Lang.format("$1$ % ", [ Battery.format ( "%2d" ) ] );
        	    return;
			}
			
			//Draw Day and week of year
			if (displayInfo == 10) {
				date.builddayWeekStr();
				//labelText = date.dayWeekStr;
				labelText = date.aktDay + " / " + date.week;
				return;
			}
			
			//next / over next sun event
			if (displayInfo == 11) {
				buildSunsetStr();
				return;
		    }
		    
		   	//heart rate
			if (displayInfo == 12) {
			var hasHR = (ActivityMonitor has :HeartRateIterator) ? true : false;			
				if (hasHR) {
					var HRH = ActMonitor.getHeartRateHistory(null, true);
					var hr="--";
					
					if(HRH != null) {
						var HRS=HRH.next();
						if(HRS!=null && HRS.heartRate!=null && HRS.heartRate!=ActMonitor.INVALID_HR_SAMPLE) {
							hr = HRS.heartRate.toString();
							labelText = hr;
							labelInfoText = "bpm";
							//labelText = HRH.getMax()+"/"+HRH.getMin()+" "+HRS.heartRate+" bpm";			
						}
					}	
				}
				else {
				labelText = "no sensor";
				}				
				return;
		    }
		   		    	    
		    
		   	//heart rate
			/*if (displayInfo == 12) {
			var hasHR = (ActivityMonitor has :HeartRateIterator) ? true : false;			
				if (hasHR) {
					var HRH = ActMonitor.getHeartRateHistory(null, true);
					var hr="--";
					
					if(HRH != null) {
						var HRS=HRH.next();
						if(HRS!=null && HRS.heartRate!=null && HRS.heartRate!=ActMonitor.INVALID_HR_SAMPLE) {
							hr = HRS.heartRate.toString();
							labelText = hr;
							labelInfoText = "bpm";
							//labelText = HRH.getMax()+"/"+HRH.getMin()+" "+HRS.heartRate+" bpm";			
						}
					}	
				}
				else {
				labelText = "no sensor";
				}				
		    }*/
		   		    	    
	}		
	
	// Time expensive function to draw static items on the watchface
	function redrawBackground(targetDc){
		// Clear the screen--------------------------------------------
        //dc.setColor(App.getApp().getProperty("BackgroundColor"), Gfx.COLOR_TRANSPARENT));
        //var BGColor=0x000001;
        var BGColor= App.getApp().getProperty("BackgroundColor");
        targetDc.setColor(Gfx.COLOR_TRANSPARENT, BGColor);
        targetDc.clear();
      
	  	drawGrid(targetDc);
	    drawGauges(targetDc);
        drawHashMarks(targetDc);  
        drawQuarterHashmarks(targetDc);  
     
		//!progress battery------------
		var BatProgressEnable = (App.getApp().getProperty("BatProgressEnable"));
       	if (BatProgressEnable) {
			drawBattery(targetDc);
		}
		//!progress steps--------------
		var StepProgressEnable = (App.getApp().getProperty("StepProgressEnable"));
       	if (StepProgressEnable) {
			drawStepGoal(targetDc);
		}
		
		 //! Moon phase
		var MoonEnable = (App.getApp().getProperty("MoonEnable"));
		if (MoonEnable) {             			
	   		var now = Time.now();
			var dateinfo = Calendar.info(now, Time.FORMAT_SHORT);
	        var clockTime = Sys.getClockTime();
	        var moon = new Moon(Ui.loadResource(Rez.Drawables.moon), moonwidth, moonx, moony);
			moon.updateable_calcmoonphase(targetDc, dateinfo, clockTime.hour);
			targetDc.setColor((App.getApp().getProperty("QuarterNumbersColor")), Gfx.COLOR_TRANSPARENT);
			targetDc.setPenWidth(1);	   
	 		targetDc.drawCircle(moonx+moonwidth/2,moony+moonwidth/2,moonwidth/2-1);
	 		
	 		//dc.setColor((App.getApp().getProperty("NumbersColor")), Gfx.COLOR_TRANSPARENT);
	 		//dc.drawText(moonx+moonwidth/2,moony+moonwidth/2-12, fontLabel, moon.c_moon_label, Gfx.TEXT_JUSTIFY_CENTER);
			//dc.drawText(moonx+moonwidth/2,moony+moonwidth/2, fontLabel, moon.c_phase, Gfx.TEXT_JUSTIFY_CENTER);
		} 	
		
        // Draw the numbers --------------------------------------------------------------------------------------
        var NbrFont = (App.getApp().getProperty("Numbers")); 
        targetDc.setColor((App.getApp().getProperty("NumbersColor")), Gfx.COLOR_TRANSPARENT);
        var font1 = 0;  
        var rightNum="3";
        var leftNum="9";
        var twelveNum;
        var iconDrop = 20;
        //var twelveFont;
       
		if (App.getApp().getProperty("ConnectionIndicator") < 2){
			twelveNum=0;
		} else {
			if (Sys.getDeviceSettings().phoneConnected) {
				if ((App.getApp().getProperty("ConnectionIndicator") % 2) == 0) {
					twelveNum = ConnectedPhoneIcon;
				} else {
					twelveNum = 0;
				}
			} else {
				if (App.getApp().getProperty("ConnectionIndicator") > 2) {
					twelveNum= DisconnectedPhoneIcon;
				} else {
					twelveNum= 0;
				}
			}
		}

        if (screenShape == 1) {  // round
   		    if ( NbrFont == 1) { //fat 12 only
	    		font1 = Ui.loadResource(Rez.Fonts.id_font_fat);
	    		if (twelveNum == 0) {
					targetDc.drawText((width / 2), 5, font1, "12", Gfx.TEXT_JUSTIFY_CENTER);
				} else {
					targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
				}
			
	    	}            
		    if ( NbrFont == 2) { //fat
		    		font1 = Ui.loadResource(Rez.Fonts.id_font_fat);
		    		if (twelveNum == 0) {
						targetDc.drawText((width / 2), 5, font1, "12", Gfx.TEXT_JUSTIFY_CENTER);
					} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
	    			targetDc.drawText(width - 16, (height / 2) - 26, font1, rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		targetDc.drawText(width / 2, height - 54, font1, "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 26, font1, leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		    	}
		    if ( NbrFont == 3) { //race
		    		font1 = Ui.loadResource(Rez.Fonts.id_font_race);
		    		if (twelveNum == 0) {
						targetDc.drawText((width / 2), 5, font1, "12", Gfx.TEXT_JUSTIFY_CENTER);
					} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
	    			targetDc.drawText(width - 16, (height / 2) - 26, font1, rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		targetDc.drawText(width / 2, height - 52, font1, "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 26, font1, leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		    	}
		    if ( NbrFont == 4) { //classic
		    		font1 = Ui.loadResource(Rez.Fonts.id_font_classic);
		    		if (twelveNum == 0) {
						targetDc.drawText((width / 2), 15, font1, "12", Gfx.TEXT_JUSTIFY_CENTER);
					} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
	    			targetDc.drawText(width - 16, (height / 2) - 18, font1, rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		targetDc.drawText(width / 2, height - 48, font1, "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 18, font1, leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		    	}
		   if ( NbrFont == 5) {  //roman
		    		font1 = Ui.loadResource(Rez.Fonts.id_font_roman);
		    		if (twelveNum == 0) {
						targetDc.drawText((width / 2), 7, font1, "}", Gfx.TEXT_JUSTIFY_CENTER);
					} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
	    			targetDc.drawText(width - 16, (height / 2) - 22, font1, rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		targetDc.drawText(width / 2, height - 50, font1, "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 22, font1, leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		   		}
		   	if ( NbrFont == 6) {  //simple
		   			if (twelveNum == 0) {
						targetDc.drawText((width / 2), 10, Gfx.FONT_SYSTEM_LARGE, "12", Gfx.TEXT_JUSTIFY_CENTER);
					} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
	    			targetDc.drawText(width - 16, (height / 2) - 22, Gfx.FONT_SYSTEM_LARGE  , rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		targetDc.drawText(width / 2, height - 45, Gfx.FONT_SYSTEM_LARGE   , "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 22, Gfx.FONT_SYSTEM_LARGE   , leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		   		}
	   	}
       
       
       if (screenShape == 2) {  //semi round
       		iconDrop = 2;
   		    if ( NbrFont == 1) { //fat
	    		font1 = Ui.loadResource(Rez.Fonts.id_font_fat);
	    		if (twelveNum == 0) {
					targetDc.drawText((width / 2), -12, font1, "12", Gfx.TEXT_JUSTIFY_CENTER);
				} else {
					targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
				}
		    }
                  
		    if ( NbrFont == 2) { //fat
		    		font1 = Ui.loadResource(Rez.Fonts.id_font_fat);
		    		if (twelveNum == 0) {
						targetDc.drawText((width / 2), -12, font1, "12", Gfx.TEXT_JUSTIFY_CENTER);
		    		} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
					if (! MoonEnable) {	
		    			targetDc.drawText(width - 16, (height / 2) - 26, font1, rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		}
	        		targetDc.drawText(width / 2, height - 41, font1, "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 26, font1, leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		    }
		    if ( NbrFont == 3) { //race
		    		font1 = Ui.loadResource(Rez.Fonts.id_font_race);
		    		if (twelveNum == 0) {
						targetDc.drawText((width / 2), -12, font1, "12", Gfx.TEXT_JUSTIFY_CENTER);
		    		} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
					if (! MoonEnable) {		
		    			targetDc.drawText(width - 16, (height / 2) - 26, font1, rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		}
	        		targetDc.drawText(width / 2, height - 39, font1, "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 26, font1, leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		    	}
		    if ( NbrFont == 4) { //classic
		    		font1 = Ui.loadResource(Rez.Fonts.id_font_classic);
		    		if (twelveNum == 0) {
						targetDc.drawText((width / 2), 0, font1, "12", Gfx.TEXT_JUSTIFY_CENTER);
		    		} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
					if (! MoonEnable) {		
		    			targetDc.drawText(width - 16, (height / 2) - 18, font1, rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		}
	        		targetDc.drawText(width / 2, height - 33, font1, "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 18, font1, leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		    	}
		   if ( NbrFont == 5) {  //roman
		    		font1 = Ui.loadResource(Rez.Fonts.id_font_roman);
		    		if (twelveNum == 0) {
						targetDc.drawText((width / 2), -4, font1, "}", Gfx.TEXT_JUSTIFY_CENTER);
		    		} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
					if (! MoonEnable) {		
		    			targetDc.drawText(width - 16, (height / 2) - 22, font1, rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		}
	        		targetDc.drawText(width / 2, height - 40, font1, "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 22, font1, leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		   		}
		   	if ( NbrFont == 6) {  //simple
		    		if (twelveNum == 0) {
						targetDc.drawText((width / 2), -3, Gfx.FONT_SYSTEM_LARGE   , "12", Gfx.TEXT_JUSTIFY_CENTER);
		    		} else {
						targetDc.drawText((width / 2), iconDrop, fontIcons, twelveNum, Gfx.TEXT_JUSTIFY_CENTER);
					}
					if (! MoonEnable) {		
		    			targetDc.drawText(width - 16, (height / 2) - 17, Gfx.FONT_SYSTEM_LARGE  , rightNum, Gfx.TEXT_JUSTIFY_RIGHT);
	        		}
	        		targetDc.drawText(width / 2, height - 30, Gfx.FONT_SYSTEM_LARGE   , "6", Gfx.TEXT_JUSTIFY_CENTER);
	        		targetDc.drawText(16, (height / 2) - 17, Gfx.FONT_SYSTEM_LARGE   , leftNum, Gfx.TEXT_JUSTIFY_LEFT);
		   		}
	   	} 
	   	
		//! Markers for sunrise and sunset
		var SunmarkersEnable = (App.getApp().getProperty("SunMarkersEnable"));		
       	if (SunmarkersEnable && screenShape == 1) {
			extras.drawSunMarkers(targetDc);
		}		
	   	
	    var LowerDispEnable = (App.getApp().getProperty("LDInfo")!=0);
        if (LowerDispEnable) {
			//background for lower display
			if (App.getApp().getProperty("ShowDigitalBackground")) {
			  targetDc.setColor(App.getApp().getProperty("DigitalBackgroundColor"), Gfx.COLOR_TRANSPARENT);  
	       	  targetDc.fillRoundedRectangle(LLBGx, LLBGy , LLBGwidth, 28, 5);
	       	  }
        }

	}
	
//-----------------------------------------------------------------------------------------------
// Handle the update event-----------------------------------------------------------------------
    function onUpdate(dc) {
    
   	//Sys.println("width = " + width);
	//Sys.println("height = " + height);
	
	    // We always want to refresh the full screen when we get a regular onUpdate call.
        fullScreenRefresh = true;

		var targetDc = null;
        if(null != offscreenBuffer) {
            dc.clearClip();
            // If we have an offscreen buffer that we are using to draw the background,
            // set the draw context of that buffer as our target.
			if (Gfx has :createBufferedBitmap) {
            	targetDc = offscreenBuffer.get().getDc();
			} else {
				targetDc = offscreenBuffer.getDc();
			}
        } else {
            targetDc = dc;
        }

          
        redrawBackground(targetDc);

  // Draw hands under a lot sorta out of order ------------------------------------         
    	if (App.getApp().getProperty("HandsBehind")) {
    	   hands.drawHands(targetDc); 
    	 }
		
		
		//! Alm / Msg indicators
		var AlmMsgEnable = (App.getApp().getProperty("AlmMsgEnable"));
		var AlmMsg = (App.getApp().getProperty("AlmMsg"));

		
		if (AlmMsgEnable) {
			var offcenter=width/6 - 5;
			var labelLeft = "";
			var labelRight = "";
			//var infoLeft = "";
			//var infoRight = "";
			infoLeft = "";
			infoRight = "";
			
			targetDc.setColor((App.getApp().getProperty("QuarterNumbersColor")), Gfx.COLOR_TRANSPARENT);
			var messages = Sys.getDeviceSettings().notificationCount;
			var alarm = Sys.getDeviceSettings().alarmCount; 
			
			if (AlmMsg == 1) { // setting Alm/Msg count		     	
		     	labelLeft = "Alm";
		     	infoLeft = alarm;
		     	
	     		labelRight = "Msg";
				infoRight = messages; 
			} 	     	
	 	    
	 	    if (AlmMsg == 2) { // setting Alm/Msg only indicators 
	 	    	labelLeft = "Alm";		     	
	     		labelRight = "Msg";	
				//messages
				if (!App.getApp().getProperty("UseIcons")){
					if (messages > 0) {
 	     		    	targetDc.fillCircle(width / 2 + offcenter, height / 2 -7, 5);
 	     			}
 	     			targetDc.setPenWidth(2);

 	        		targetDc.drawCircle(width / 2 + offcenter, height / 2 -7, 5);
 	        	}	
 	        		     		     	
				//Alarm		     	
 	     		if (!App.getApp().getProperty("UseIcons")){
 	     			if (alarm > 0) {
 	     				targetDc.fillCircle(width / 2 - offcenter, height / 2 -7, 5);
 	     			}
 	     			targetDc.setPenWidth(2);
 	        		targetDc.drawCircle(width / 2 - offcenter, height / 2 -7, 5);
 	        	}
	     	} 
	     	
	     	if (AlmMsg == 3) { 
	     		date.builddayWeekStr();    	
	     		labelLeft = "day";
	     		infoLeft = date.aktDay;
	     		labelRight = "week";				
				infoRight = date.week;     	
	     	}
	     	
	     	if (AlmMsg == 4) { 
	     		buildSunsetStr();    	
	     		labelLeft = "s.rise";
	     		labelRight = "s.set";				   	
	     	}
	     	
	     	if (AlmMsg == 5) { 
	     		drawAltitude();    	
	     		labelLeft = "elev";	     		
	     		distance.drawDistance();
	     		labelRight = "dist";				
				infoRight = distance.distStr;    	
	     	}
	     	
	     	if (AlmMsg == 6) {    	
	     		labelLeft = "goal";	     		
	     		infoLeft = ActMonitor.getInfo().stepGoal;
	     		labelRight = "steps";				
				infoRight = ActMonitor.getInfo().steps;    	
	     	}


	     	if (App.getApp().getProperty("UseIcons")&&(AlmMsg<=2))
	     	{
	     		//Sys.println("Using icons");
	     		var xtiny_correction = 10; //Gfx.getFontHeight(Gfx.FONT_TINY)/2 + 2;
	     		//Sys.println("font ascent = "+xtiny_correction);

	     		if (AlmMsg==1)
	     		{
	     			if (messages > 0) {
	     				targetDc.drawText(width / 2 + offcenter +4, height / 2 -10, fontIcons, MessageIcon, Gfx.TEXT_JUSTIFY_LEFT);    //message icon
	     				targetDc.drawText(width / 2 + offcenter, height / 2 -xtiny_correction, fontLabel, messages, Gfx.TEXT_JUSTIFY_RIGHT);  //# of messages
	     			}
	 				if (alarm>0) {
	 					targetDc.drawText(width / 2 - offcenter -4, height / 2 -10, fontIcons, AlarmIcon, Gfx.TEXT_JUSTIFY_RIGHT);  //alarm icon
	 					targetDc.drawText(width / 2 - offcenter, height / 2 -xtiny_correction, fontLabel, alarm, Gfx.TEXT_JUSTIFY_LEFT);	  //# of alarms
	 				}
	     			   		
	 			}
	 			if (AlmMsg==2)
	 				{
	 				if (messages > 0) {
 	     		    	targetDc.drawText(width / 2 + offcenter, height / 2 -8, fontIcons,MessageIcon,Gfx.TEXT_JUSTIFY_CENTER);
 	     			}
 	     			if (alarm>0) {
 	     				targetDc.drawText(width / 2 - offcenter, height / 2 -8, fontIcons,AlarmIcon,Gfx.TEXT_JUSTIFY_CENTER);
 	     			}
	 			}
	     	}
	     	else
	     	{	
			targetDc.drawText(width / 2 + offcenter, height / 2 -15, fontLabel, infoRight, Gfx.TEXT_JUSTIFY_CENTER);	     		
	 		targetDc.drawText(width / 2 + offcenter, height / 2 -2, fontLabel, labelRight, Gfx.TEXT_JUSTIFY_CENTER);
	 		
	 		targetDc.drawText(width / 2 - offcenter, height / 2 -15, fontLabel, infoLeft, Gfx.TEXT_JUSTIFY_CENTER);
	 		targetDc.drawText(width / 2 - offcenter, height / 2 -2, fontLabel, labelLeft, Gfx.TEXT_JUSTIFY_CENTER);
	 		} 
		}       



//Draw Digital Elements ------------------------------------------------------------------ 

	    var fontDigital = 0;
	   

         var digiFont = (App.getApp().getProperty("DigiFont")); 
         //Sys.println("digiFont="+ digiFont);
         //fontDigital = null;
         
    	//font for display
	    if ( digiFont == 1) { //!digital
	    	fontDigital = Ui.loadResource(Rez.Fonts.id_font_digital); 
	    	//fontDigital = Gfx.FONT_SYSTEM_MEDIUM ;
	    	//Sys.println("set digital");    
	    	}
	    if ( digiFont == 2) { //!classik
        	fontDigital = Ui.loadResource(Rez.Fonts.id_font_classicklein); 
        	//fontDigital = Gfx.FONT_SYSTEM_MEDIUM ;
        	//Sys.println("set classic");     
	    	}
	    if ( digiFont == 3) { //!simple
	    	if (screenShape == 1) {  // round 
        		fontDigital = Gfx.FONT_SYSTEM_MEDIUM ; 
        	}
        	if (screenShape == 2) {  // semi round 
        		fontDigital = Gfx.FONT_SYSTEM_LARGE ; 
        	}      	    
	    }
	    	
		//Anzeige oberes Display--------------------------  
	    var UpperDispEnable = (App.getApp().getProperty("UDInfo")!=0);
		if (UpperDispEnable) {
			var displayInfo = (App.getApp().getProperty("UDInfo"));
		//	Sys.println("UDInfo: " + displayInfo);
			setLabel(displayInfo);
			//background for upper display
			if (App.getApp().getProperty("ShowDigitalBackground")) {
			  targetDc.setColor(App.getApp().getProperty("DigitalBackgroundColor"), Gfx.COLOR_TRANSPARENT);  
	       	  targetDc.fillRoundedRectangle(ULBGx, ULBGy , ULBGwidth, 38, 5);
	       	  }
      	      	 
        	targetDc.setColor((App.getApp().getProperty("ForegroundColor")), Gfx.COLOR_TRANSPARENT);
        	targetDc.drawText(ULTEXTx, ULTEXTy, fontDigital, labelText, Gfx.TEXT_JUSTIFY_CENTER);	
        	//targetDc.drawText(ULTEXTx, ULTEXTy, fontDigital, "88:88/88:88", Gfx.TEXT_JUSTIFY_CENTER);	
			targetDc.drawText(ULINFOx, ULINFOy, fontLabel, labelInfoText, Gfx.TEXT_JUSTIFY_RIGHT);
			
			if (displayInfo == 4) {
				drawStepGraph(targetDc, ULTEXTx, ULTEXTy, ULINFOx, ULINFOy);
			}	    				
			if (displayInfo == 5) {
				bat_hist.update();
				bat_hist.draw(targetDc, ULTEXTx, ULTEXTy);
			}	    				
		}	
		
			
	 //Anzeige unteres Display--------------------------  
	    var LowerDispEnable = (App.getApp().getProperty("UDInfo")!=0);
		if (LowerDispEnable) {
			var displayInfo = (App.getApp().getProperty("LDInfo"));
		//	Sys.println("LDInfo: " + displayInfo);
			setLabel(displayInfo);
	       	      	      	 
        	targetDc.setColor((App.getApp().getProperty("ForegroundColor")), Gfx.COLOR_TRANSPARENT);
        	targetDc.drawText(LLTEXTx, LLTEXTy, fontDigital, labelText, Gfx.TEXT_JUSTIFY_CENTER);
       // 	dc.drawText(LLTEXTx-25, LLTEXTy, fontDigital, "88888", Gfx.TEXT_JUSTIFY_CENTER);		
			targetDc.drawText(LLINFOx, LLINFOy, fontLabel, labelInfoText, Gfx.TEXT_JUSTIFY_RIGHT);
			
			if (displayInfo == 4) {
				drawStepGraph(targetDc, LLTEXTx, LLTEXTy, LLINFOx, LLINFOy);
			}	    				
			if (displayInfo == 5) {
				bat_hist.update();
				bat_hist.draw(targetDc, ULTEXTx, ULTEXTy);
			}	    				
		}

//Fadenkreuz-------------------------------------
	  	//dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
//	  	dc.setPenWidth(1);  	
//		dc.drawLine(ULBGx, 0, ULBGx , height);
//		dc.drawLine(ULBGx + ULBGwidth, 0, ULBGx + ULBGwidth , height);	
//		dc.drawLine(width/2, 0, width/2 , height);		
//		dc.drawLine(0, height/2, width , height/2);

	
//draw move bar (inactivity alarm)----------------------
//Sys.println("moveBarLevel "+ ActMonitor.getInfo().moveBarLevel);
var showMoveBar = (App.getApp().getProperty("MoveBarEnable"));

var setY = ULBGy + 40 ;
var setX = center_x;

	if (showMoveBar) {
	targetDc.setPenWidth(3);
	
		targetDc.setColor(App.getApp().getProperty("QuarterNumbersColor"), Gfx.COLOR_TRANSPARENT);
		if (ActMonitor.getInfo().moveBarLevel >= 1) {
			targetDc.drawLine(setX - 7 , setY, setX  - 58, setY);		
		//	dc.fillRoundedRectangle(ULBGx , setY, ULBGwidth/2 - 2 , 3, 3);
		}
		
		
		if (ActMonitor.getInfo().moveBarLevel >= 2) {
			targetDc.drawLine(setX , setY, setX + 10, setY);
			setX = setX +  16;
		//	dc.fillRoundedRectangle(ULBGx + ULBGwidth/2, setY, ULBGwidth/8 - 2 , 3, 3);
		}
		if (ActMonitor.getInfo().moveBarLevel >= 3) {
			targetDc.drawLine(setX , setY, setX + 10, setY);
			setX = setX +  16;
		//	dc.fillRoundedRectangle(ULBGx  + ULBGwidth/2 + ULBGwidth/8, setY, ULBGwidth/8 - 2 , 3, 3);
		}
		if (ActMonitor.getInfo().moveBarLevel >= 4) {
			targetDc.drawLine(setX , setY, setX + 10, setY);
			setX = setX +  16;
		//	dc.fillRoundedRectangle(ULBGx  + ULBGwidth/2 + ULBGwidth/8 * 2, setY, ULBGwidth/8 - 2 , 3, 3);
		}
		if (ActMonitor.getInfo().moveBarLevel == 5) {
			targetDc.drawLine(setX , setY, setX + 10, setY);
		//	dc.fillRoundedRectangle(ULBGx  + ULBGwidth/2 + ULBGwidth/8 * 3, setY, ULBGwidth/8 + 2 , 3, 3);
		}
	}	  	
	 
		// Draw hands ------------------------------------------------------------------         
		if (!App.getApp().getProperty("HandsBehind")) {
    	   hands.drawHands(targetDc); 
    	 }     	
     	

/* 
 		//Draw crosshairs for positioning things
 		targetDc.setColor((App.getApp().getProperty("QuarterNumbersColor")), Gfx.COLOR_TRANSPARENT);
 		targetDc.setPenWidth(2);
 		targetDc.drawLine(width/2,0,width/2,height);
 		targetDc.drawLine(0,height/2,width,height/2);
*/
        

  		// Center Point with Bluetooth connection
	  	//if ((App.getApp().getProperty("CenterDotEnable"))) {
	  	if ((App.getApp().getProperty("ConnectionIndicator") ==1) && !(Sys.getDeviceSettings().phoneConnected)) {
				targetDc.setColor((App.getApp().getProperty("BackgroundColor")), Gfx.COLOR_TRANSPARENT);
		} else {
  			targetDc.setColor((App.getApp().getProperty("HandsColor2")), Gfx.COLOR_TRANSPARENT);
	   	} 
	    targetDc.fillCircle(width / 2, height / 2, 5);
	    targetDc.setPenWidth(2);
     	targetDc.setColor((App.getApp().getProperty("HandsColor2")), Gfx.COLOR_TRANSPARENT);
	    targetDc.drawCircle(width / 2, height / 2 , 5);

 		// Output the offscreen buffers to the main display if required.
        drawBackground(dc);

		sec_hands_form = App.getApp().getProperty("SecHandsForm");
		sec_hands_color1 = App.getApp().getProperty("SecHands1Color");
		sec_hands_color2 = App.getApp().getProperty("SecHands2Color");
		if ( partialUpdatesAllowed && (sec_hands_form == 3 )) {
            // If this device supports partial updates and they are currently
            // allowed run the onPartialUpdate method to draw the second hand.
            //Sys.println("Entering onPartialUpdate");
            onPartialUpdate( dc );
        } else if (isAwake) {
			//var SecHandEnable = (App.getApp().getProperty("SecHandEnable"));
			if (sec_hands_form > 0) {
				//Sys.println("Entering drawSecHands with arg: "+SecHandStyle);
				hands.drawSecondHands(dc, partialUpdatesAllowed, sec_hands_form, sec_hands_color1, sec_hands_color2);
			}
 		}

	//Sys.println("used: " + System.getSystemStats().usedMemory);
	//Sys.println("free: " + System.getSystemStats().freeMemory);
	//Sys.println("total: " + System.getSystemStats().totalMemory);
	//Sys.println("");
			fullScreenRefresh = false;
			
	} // end onUpdate(dc)-----------------------------------
		

    // Handle the partial update event
    function onPartialUpdate( dc ) {
        // If we're not doing a full screen refresh we need to re-draw the background
        // before drawing the updated second hand position. Note this will only re-draw
        // the background in the area specified by the previously computed clipping region.
		var start = Sys.getTimer();
        if(sec_hands_form != 3) {  //draw 1Hz second hand if you so chose
        	return;
        }

        if(!fullScreenRefresh) {
            drawBackground(dc);
        }


		hands.drawSecondHands(dc, true, sec_hands_form, sec_hands_color1, sec_hands_color2);

        // // Draw the second hand to the screen.
        // dc.setColor(sec_hands_color2, Graphics.COLOR_TRANSPARENT);
        // dc.fillPolygon(secondHandPoints);
 			
 		fullScreenRefresh = false;
		var t = Sys.getTimer() - start;
		if (t > 25) {
			System.println("partian update took: " + t); 			
		}
	}


    function drawBackground(dc) {
        //If we have an offscreen buffer that has been written to
        //draw it to the screen.
        if( offscreenBuffer != null) {
            dc.drawBitmap(0, 0, offscreenBuffer);
        }
    }

    function onEnterSleep() {
        isAwake = false;
        Ui.requestUpdate();
    }

    function onExitSleep() {
        isAwake = true;
    }
}

class AnalogDelegate extends Ui.WatchFaceDelegate {

	function initialize() {
		WatchFaceDelegate.initialize();	
	}
    // The onPowerBudgetExceeded callback is called by the system if the
    // onPartialUpdate method exceeds the allowed power budget. If this occurs,
    // the system will stop invoking onPartialUpdate each second, so we set the
    // partialUpdatesAllowed flag here to let the rendering methods know they
    // should not be rendering a second hand.
    function onPowerBudgetExceeded(powerInfo) {
        System.println( "Average execution time: " + powerInfo.executionTimeAverage );
        System.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
        // partialUpdatesAllowed = false;
    }
}

