// Battery history
using Toybox.Time as Time;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

const _history_size = 100;
const _graph_height = 30;
const STOR_ID_HISTORY = "HIST";
const STOR_ID_LAST_TS = "LAST";

class BatHist {
	var ts_last_update_hour = 0;
	var history;
	var center_y, center_x;

    function initialize(cent_x, cent_y) {
		var app = App.getApp();
		history = app.getProperty(STOR_ID_HISTORY);
		ts_last_update_hour = app.getProperty(STOR_ID_LAST_TS);

		if (history == null) {
		    history = new[_history_size];
			for (var i = 0; i < _history_size; i++) {
				history[i] = i;					
			}
		}
		if (ts_last_update_hour == null) {
			ts_last_update_hour = System.getClockTime().hour;
		}
		center_x = cent_x;
		center_y = cent_y;
	}


	function update() {
		var hour = System.getClockTime().hour;
		if (hour != ts_last_update_hour) {
			for (var i = 0; i < _history_size - 1; i++) {
				history[i] = history[i + 1];					
			}
			history[_history_size - 1] = Toybox.System.getSystemStats().battery;
			ts_last_update_hour += 1;
			ts_last_update_hour %= 24;

			var app = App.getApp();
			app.setProperty(STOR_ID_HISTORY, history);
			app.setProperty(STOR_ID_LAST_TS, ts_last_update_hour);
		}
	}

	function draw(dc) {
		var posx = center_x - _history_size / 2;
		var posy = center_y - _graph_height / 2 + 15;
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);

  		dc.drawRectangle(posx, posy, _history_size, _graph_height);
		for (var i = 0; i < _history_size; i++) {
			if (history[i] <= 25){ dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);}
			else if (history[i] <= 40) {dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);}
			else {dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);}

			var p = posy + _graph_height - history[i] * _graph_height / 100;
	  		dc.drawLine(posx, posy + _graph_height, posx, p);
			posx += 1;
		}
	}

}
	