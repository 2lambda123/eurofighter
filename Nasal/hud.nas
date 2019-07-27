var HUD_SCREEN = {

    canvas_settings: {
        "name": "HUD_SCREEN",
        "size": [1024, 1024],
        "view": [1024, 1024],
        "mipmapping": 1
    },
    new: func(placement) {
        var m = {
            parents: [HUD_SCREEN],
            hud: canvas.new(HUD_SCREEN.canvas_settings)
        };


        m.cur_main_func = nil;
        m.cur_init_func = nil;
        m.cur_end_func = nil;
        m.cur_state = nil;
        
        ###############################
        ###################### settings
        ###############################
        
        m.update_rate = 0.1;
        
        m.line_width = 3;
        m.dot_circ = 5;
        
        m.font_size = 18;
        m.font = "led-5-7.txf";
        
        m.red = 0.3;
        m.green = 1.0;
        m.blue = 0.15;
        
        # pitch bars
        m.pitch_bars_deg_shown = 25;
        m.pitch_bars_deg_spacing = 5;
        m.pitch_bars_size_percent = 0.8; # how much of the hud-y to use for max size
        
        ###############################
        ##################### constants
        ###############################
        
        m.x_res_norm = m.canvas_settings["view"][0] / 1024; # dont change the 1024!
        m.y_res_norm = m.canvas_settings["view"][1] / 1024; # dont change the 852!
        m.avg_norm = (m.x_res_norm + m.y_res_norm) / 2;

        m.hud.addPlacement(placement);
        m.hud.setColorBackground(m.red,m.green,m.blue,0);
        
        ###############################
        ## view stuff
        ###############################
        
        # x and z coords of the center of the hud
        m.hud_x = -4.74837;
        m.hud_z = 1.16543;
        
        # rewrite this with whatever the current view x/z is set to
        m.view_x = -4.14417;
        m.view_z = 1.20837;
        
        m.hud_height_m = 0.25; # get this out of blender, the height of the hud in meters
        m.hud_height_px = 920; # however high the hud is in pixels
        
        ###############################
        ## pitch bars
        ###############################
        
        # calculate angle from view to center of the hud
        m.z_delta = m.view_z - m.hud_z;
        m.x_delta = m.view_x - m.hud_x;
        m.view_dist = math.sqrt(m.z_delta * m.z_delta + m.x_delta * m.x_delta);
        m.angle_to_hud = (90 * D2R) - math.asin(m.x_delta / m.view_dist);
        #print('angle to hud: ' ~ (m.angle_to_hud * R2D));
        
        # calculate how many degrees == how many pixels in a 1:1 ratio
        # get angle to the bottom of the hud
        m.z_to_bottom_delta = m.z_delta + (m.hud_height_m / 2);
        m.hypot_to_bottom = math.sqrt(m.z_to_bottom_delta * m.z_to_bottom_delta + m.x_delta * m.x_delta);
        m.angle_to_bottom = (90 * D2R) - math.asin(m.x_delta / m.hypot_to_bottom);
        
        m.px_per_degree = (m.hud_height_px / 2) / (math.abs(m.angle_to_bottom - m.angle_to_hud) * R2D);

        me.climbdive_mode = 0;

        m.pitch_bars_down = [];
        m.pitch_bars_up = [];
        m.pitch_bars_text = [];
        m.build_pitch_lookup_array();
                
        # create the actual lines
        m.pitch_bars_canvas_group = m.hud.createGroup();
        m.pitch_bars_canvas_group.setTranslation(m.canvas_settings["view"][0] / 2, m.hud_height_px / 2);
        m.pitch_bar_center = m.pitch_bars_canvas_group.createChild("path")
                                    .move(-273,0)
                                    .line(235,0)
                                    .line(0,15)
                                    .move(76,0)
                                    .line(0,-15)
                                    .line(235,0)
                                    .setStrokeLineWidth(m.line_width)
                                    .setColor(m.red,m.green,m.blue);
        for(var i = 0; i < 180 / 5; i = i + 1) {
            append(m.pitch_bars_down, m.pitch_bars_canvas_group.createChild("path")
                                        .move(-123,-17)
                                        .line(0,17)
                                        .line(19,0)
                                        .move(14,0)
                                        .line(18,0)
                                        .line(8,-9)
                                        .line(8,9)
                                        .line(18,0)
                                        .move(76,0)
                                        .line(18,0)
                                        .line(8,-9)
                                        .line(8,9)
                                        .line(18,0)
                                        .move(14,0)
                                        .line(19,0)
                                        .line(0,-17)
                                        .setStrokeLineWidth(m.line_width)
                                        .setColor(m.red,m.green,m.blue));
            append(m.pitch_bars_up, m.pitch_bars_canvas_group.createChild("path")
                                        .move(-125,17)
                                        .line(0,-17)
                                        .line(87,0)
                                        .move(76,0)
                                        .line(87,0)
                                        .line(0,17)
                                        .setStrokeLineWidth(m.line_width)
                                        .setColor(m.red,m.green,m.blue));
            append(m.pitch_bars_text, m.pitch_bars_canvas_group.createChild("text")
                                        .setAlignment("left-center")
                                        .setFontSize(m.font_size)
                                        .setFont(m.font)
                                        .setColor(m.red,m.green*2,m.blue,1));
        }

        m.nadir = m.pitch_bars_canvas_group.createChild("path")
                                        # circle with 5 lines going horizontally inside, and one line coming out the top
                                        .move(0,-15)
                                        .ArcSmallCW(15,15,0,8,2)
                                        .line(-16,0)
                                        .move(16,0)
                                        .ArcSmallCW(15,15,0,5,5)
                                        .line(-26,0)
                                        .move(26,0)
                                        .ArcSmallCW(15,15,0,2,8)
                                        .line(-30,0)
                                        .move(30,0)
                                        .ArcSmallCW(15,15,0,-2,8)
                                        .line(-26,0)
                                        .move(26,0)
                                        .ArcSmallCW(15,15,0,-5,5)
                                        .line(-16,0)
                                        .move(16,0)
                                        .ArcSmallCW(15,15,0,-8,2)
                                        .ArcSmallCW(15,15,0,0,-15)
                                        .line(0,-30)
                                        .setStrokeLineWidth(m.line_width)
                                        .setColor(m.red,m.green,m.blue);

        m.zenith = m.pitch_bars_canvas_group.createChild("path")
                                        # star with a droopy bottom
                                        .move(0,-30)
                                        .line(-5,20)
                                        .line(-7,-2)
                                        .line(2,7)
                                        .line(-20,4)
                                        .line(20,5)
                                        .line(-2,6)
                                        .line(7,-2)
                                        .line(5,82)
                                        .line(5,-82)
                                        .line(7,2)
                                        .line(-2,-6)
                                        .line(20,-5)
                                        .line(-20,-4)
                                        .line(2,-7)
                                        .line(-7,2)
                                        .line(-5,-20)
                                        .setStrokeLineWidth(m.line_width)
                                        .setColor(m.red,m.green,m.blue);


        ###############################
        ## flight direction indicators
        ###############################
        
        m.flight_dir_indicators = m.hud.createGroup();
        m.flight_dir_indicators.setTranslation(m.canvas_settings["view"][0] / 2, m.hud_height_px / 2);
        m.climbdive_symbol = m.flight_dir_indicators.createChild("path")
                                .move(-9,0)
                                .arcSmallCW(9,9,0,18,0)
                                .arcSmallCW(9,9,0,-18,0)
                                .line(-25,0)
                                .move(43,0)
                                .line(25,0)
                                .setStrokeLineWidth(m.line_width)
                                .setColor(m.red,m.green,m.blue)
                                .hide();
        m.attitude_symbol = m.flight_dir_indicators.createChild("path")
                                .move(-34,0)
                                .line(68,0)
                                .move(-43,9)
                                .line(9,-18)
                                .line(9,18)
                                .setStrokeLineWidth(m.line_width)
                                .setColor(m.red,m.green,m.blue);
        m.velocity_vector = m.flight_dir_indicators.createChild("path")
                                .move(-8,0)
                                .line(8,9)
                                .line(8,-9)
                                .line(-8,-9)
                                .line(-8,9)
                                .setStrokeLineWidth(m.line_width)
                                .setColor(m.red,m.green,m.blue)
                                .hide();
        
        ###############################
        ## compass
        ###############################
        m.compass_spread_deg = 35; # per hud image in docs?
        m.compass_dot_spread_deg = 5; # per hud image in docs
        m.compass_dot_spread_px = 34;
        
        m.compass_px_per_degree = m.compass_dot_spread_px / m.compass_dot_spread_deg;
        m.compass_total_spread = m.compass_spread_deg + m.compass_dot_spread_deg;
        m.compass_left_limit = (m.compass_total_spread / 2) * m.compass_px_per_degree * -1;
        
        m.compass = m.hud.createGroup();
        m.compass.setTranslation(m.canvas_settings["view"][0] / 2, m.hud_height_px / 2 - 316);
        m.compass_dots = [];
        m.compass_text = [];
        for (var i = 0; i < m.compass_spread_deg / m.compass_dot_spread_deg + 1; i = i + 1) {
            append(m.compass_dots, m.compass.createChild("path")
                                    .move(-m.dot_circ/2,0)
                                    .arcSmallCW(m.dot_circ/2, m.dot_circ/2,0,m.dot_circ, 0)
                                    .arcSmallCW(m.dot_circ/2, m.dot_circ/2,0,-m.dot_circ, 0)
                                    .setColor(m.red,m.green,m.blue)
                                    .setColorFill(m.red,m.green,m.blue));
            if (math.mod(i,2) == 0) {
                append(m.compass_text, m.compass.createChild("text")
                                        .setAlignment("center-bottom")
                                        .setFontSize(m.font_size)
                                        .setFont(m.font)
                                        .setColor(m.red,m.green,m.blue,1));
            }
        }
        m.compass_heading_marker = m.compass.createChild("path")
                                    .move(0,3)
                                    .line(0,21)
                                    .move(0,-21)
                                    .line(-8,14)
                                    .move(8,-14)
                                    .line(8,14)
                                    .setColor(m.red,m.green,m.blue)
                                    .setStrokeLineWidth(m.line_width/2);
        m.compass_route_marker = m.compass.createChild("path")
                                    .move(0,-3)
                                    .move(-8,-20)
                                    .arcSmallCW(12,12,0,16,0)
                                    .setColor(m.red,m.green,m.blue)
                                    .setStrokeLineWidth(m.line_width)
                                    .hide();
                                    
        
        ###############################
        ## altitude circle
        ###############################
        m.alt_num_dots = 10;
        m.alt_circle_radius = 92 / 2;
        m.alt_line_inner_radius = 30;
        m.alt_line_outer_radius = 46;
        m.alt_rotations_per_foot = 1/1000; # one rotation every thousand feet
        
        m.alt_deg_per_dot = 360 / m.alt_num_dots;
        
        m.alt_display = m.hud.createGroup();
        m.alt_display.setTranslation(700, 300);
        m.alt_dots = [];
        
        for (var i = 0; i < m.alt_num_dots; i = i + 1) {
            m.angle = (i * m.alt_deg_per_dot + 180) * D2R;
            m.x = math.sin(m.angle) * m.alt_circle_radius;
            m.y = math.cos(m.angle) * m.alt_circle_radius;
            #print(m.x ~ "|" ~ m.y);
            append(m.alt_dots, m.alt_display.createChild("path")
                                    .move(-m.dot_circ/2,0)
                                    .arcSmallCW(m.dot_circ/2, m.dot_circ/2,0,m.dot_circ, 0)
                                    .arcSmallCW(m.dot_circ/2, m.dot_circ/2,0,-m.dot_circ, 0)
                                    .setTranslation(m.x,m.y)
                                    .setColor(m.red,m.green,m.blue)
                                    .setColorFill(m.red,m.green,m.blue));
        }
        m.alt_line = m.alt_display.createChild("path")
                                    .move(0,-m.alt_line_outer_radius)
                                    .line(0,m.alt_line_inner_radius)
                                    .setColor(m.red,m.green,m.blue)
                                    .setStrokeLineWidth(m.line_width);
        m.alt_text = m.alt_display.createChild("text")
                                    .setAlignment("center-center")
                                    .setFontSize(m.font_size)
                                    .setFont(m.font)
                                    .setColor(m.red,m.green,m.blue,1);
            
        
        ###############################
        ## vertical speed indicator
        ###############################
        
        ###############################
        ## text
        ###############################
        m.ias_text = m.hud.createGroup().createChild("text")
                            .setAlignment("center-center")
                            .setFontSize(m.font_size)
                            .setFont(m.font)
                            .setColor(m.red,m.green,m.blue,1)
                            .setTranslation(356, 300);
        m.gs_m_mode = 0; # 0 for mach, 1 for groundspeed
        m.gs_m_display = m.hud.createGroup();
        m.gs_m_text = m.hud.createGroup().createChild("text")
                            .setAlignment("center-bottom")
                            .setFontSize(m.font_size)
                            .setFont(m.font)
                            .setColor(m.red,m.green,m.blue,1)
                            .setTranslation(290, 300 - 3)
                            .setText("M");
        m.gs_m_output = m.hud.createGroup().createChild("text")
                            .setAlignment("center-top")
                            .setFontSize(m.font_size)
                            .setFont(m.font)
                            .setColor(m.red,m.green,m.blue,1)
                            .setTranslation(290, 300 + 3);
        m.gmeter_text = [];
        m.gmeter_group = m.hud.createGroup();
        for (var i = 0; i < 3; i = i + 1) {
            append(m.gmeter_text, m.gmeter_group.createChild("text")
                            .setAlignment("right-center")
                            .setFontSize(m.font_size)
                            .setFont(m.font)
                            .setColor(m.red,m.green,mblue,1));
        }
        m.gmeter_spacing = m.font_size / 4;
        #m.gmeter_group.set("clip","rect(1px, 1px, 1px, 1px)"); # top right bottom left
        return m;
    },

    off_mode_init: func() {
        me.flight_dir_indicators.hide();
        me.pitch_bars_canvas_group.hide();
        me.compass.hide();
        me.alt_display.hide();
        me.ias_text.hide();
        me.gs_m_display.hide();
        me.gmeter_group.hide();
    },
    off_mode_update: func() {
        # the hud is off, we do nothing
        return;
    },
    
    dev_mode_init: func() {
        me.flight_dir_indicators.show();
        me.pitch_bars_canvas_group.show();
        me.compass.show();
        me.alt_display.show();
        me.ias_text.show();
        me.gs_m_display.show();
        me.pitch_bars_shown = [-90, -80, -70, -60, -50, -40, -30, -25, -20, -15, -10, -5, 0,
                                5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90]
    },
    
    dev_mode_update: func() {
        me.groundspeed_mach_text();
        me.ias_text_update();
        me.pitch_bars_display();
        me.compass_display();
        me.altitude_display();
    },

    pitch_bars_display: func() {
        me.center_hud_pitch = prop_io.pitch - (me.angle_to_hud * math.cos(prop_io.roll * D2R) * R2D);
        me.pitch_bar_center.hide();
        me.zenith.hide();
        me.nadir.hide();

        if (me.climbdive_mode == 0 and prop_io.airspeed > 48) {
            me.climbdive_mode = 1;
            me.attitude_symbol.hide();
            me.climbdive_symbol.show();
        } elsif (me.climbdive_mode == 1 and prop_io.airspeed < 48) {
            me.climbdive_mode = 0;
            me.attitude_symbol.show();
            me.climbdive_symbol.hide();
        }
        if (me.climbdive_mode == 0) {
            me.symbol_location = math.clamp(me.get_pitch_location(prop_io.pitch), -me.hud_height_px  / 2, me.hud_height_px  / 2);
            me.attitude_symbol.setTranslation(0, me.symbol_location);
            me.attitude_symbol.setRotation(prop_io.roll * D2R);
            me.pitch_bars_canvas_group.setCenter(0, me.symbol_location);
            me.flight_dir_indicators.setCenter(0, me.symbol_location);
        } elsif (me.climbdive_mode == 1) {
            me.cd_out = math.clamp(prop_io.pitch - math.clamp(prop_io.alpha,-5,15),-90,90);
            me.symbol_location = math.clamp(me.get_pitch_location(me.cd_out), -me.hud_height_px  / 2, me.hud_height_px  / 2);
            me.climbdive_symbol.setTranslation(0, me.symbol_location);
            me.climbdive_symbol.setRotation(prop_io.roll * D2R);
            me.pitch_bars_canvas_group.setCenter(0, me.symbol_location);
            me.flight_dir_indicators.setCenter(0, me.symbol_location);
        }

        me.flight_dir_indicators.setRotation(-prop_io.roll * D2R);
        me.pitch_bars_canvas_group.setRotation(-prop_io.roll * D2R);
        me.top_limit = 100;
        me.bottom_limit = me.hud_height_px - me.top_limit;
        for (var i = 0; i < size(me.pitch_bars_shown); i = i + 1){
            me.px_location = me.get_pitch_location(me.pitch_bars_shown[i]);
            #print(me.b_pitch ~ " " ~ me.px_location);
            if (int(me.pitch_bars_shown[i]) == 90 and me.px_location > -me.hud_height_px / 2){
                me.pitch_bars_down[i].hide();
                me.pitch_bars_up[i].hide();
                me.pitch_bars_text[i].hide();
                me.zenith.setTranslation(0,me.px_location).show();
            }elsif (int(me.pitch_bars_shown[i]) == -90 and me.px_location < me.hud_height_px / 2) {
                me.pitch_bars_down[i].hide();
                me.pitch_bars_up[i].hide();
                me.pitch_bars_text[i].hide();
                me.nadir.setTranslation(0,me.px_location).show();
            }elsif (me.pitch_bars_shown[i] < 0 and me.px_location < me.hud_height_px / 2) {
                me.pitch_bars_down[i].setTranslation(0,me.px_location).show();
                me.pitch_bars_up[i].hide();
                me.pitch_bars_text[i].setText(int(me.pitch_bars_shown[i])).setTranslation(-115 * me.x_res_norm,me.px_location - 25).show();
            } elsif (me.pitch_bars_shown[i] == 0) {
                #print(me.b_pitch ~ " " ~ me.px_location);
                me.pitch_bars_down[i].hide();
                me.pitch_bars_up[i].hide();
                me.pitch_bars_text[i].hide();
                me.pitch_bar_center.setTranslation(0,me.px_location).show();
            } elsif (me.pitch_bars_shown[i] > 0 and me.px_location > -me.hud_height_px / 2) {
                me.pitch_bars_up[i].setTranslation(0,me.px_location).show();
                me.pitch_bars_down[i].hide();
                me.pitch_bars_text[i].setText(int(me.pitch_bars_shown[i])).setTranslation(-115 * me.x_res_norm,me.px_location + 25).show();
            } else {
                me.pitch_bars_down[i].hide();
                me.pitch_bars_up[i].hide();
                me.pitch_bars_text[i].hide();
            }
        }
        for (var j = i; j < size(me.pitch_bars_down); j = j + 1) {
                me.pitch_bars_down[j].hide();
                me.pitch_bars_up[j].hide();
                me.pitch_bars_text[j].hide();
        }
    },

    get_pitch_location: func(p) {
        me.center_px_offset = me.get_pitch_pixel(me.center_hud_pitch);
        
        me.actual_px = (me.center_px_offset - me.get_pitch_pixel(p))  * -1;
        return me.actual_px;
    },
    get_pitch_pixel: func(p) {
        me.absp = math.abs(p);
        me.res_1 = me.pitch_lookup_array[int(me.absp)];
        me.res_2 = me.pitch_lookup_array[int(me.absp) + 1];
        me.fraction = me.absp - int(me.absp);
        return (((me.res_2 - me.res_1) * me.fraction) + me.res_1) * (math.sgn(p) * -1);
    },
    build_pitch_lookup_array: func() {
        me.pitch_lookup_array = [0];
        me.running_tally = 0;
        for (var i = 1; i <= 91; i = i + 1) {
            me.running_tally += me.px_per_degree / me.get_pitch_ratio(i);
            append(me.pitch_lookup_array,me.running_tally);
            #print(i ~ "|" ~ me.running_tally);
        }
    },
    get_pitch_ratio: func(p) {
        # at less than 5, the ratio is 1
        # from 5 to 90, the ratio increases
        # exponentially to ~4.4

        if (math.abs(p) < 5) {
            return 1;
        }

        return 0.00042 * math.pow(math.abs(p), 2) + 0.99
    },
    
    compass_display: func() {
        # me.compass_route_marker is used to show AP route heading. currently it is hide()ing.
        
        # determine leftmost dot location
        
        me.b_dot = ((prop_io.heading - (math.mod(prop_io.heading,me.compass_dot_spread_deg)) - prop_io.heading) + me.compass_dot_spread_deg);
        me.b_dot = me.b_dot * me.compass_px_per_degree + me.compass_left_limit;
        
        # determine leftmost dot number
        me.b_text = prop_io.heading - math.mod(prop_io.heading, me.compass_dot_spread_deg) - me.compass_total_spread;
        
        # update the dots
        me.text_idx = 0;
        for (var i = 0; i < me.compass_spread_deg / me.compass_dot_spread_deg + 1; i = i + 1) {
            me.compass_dots[i].setTranslation(me.b_dot,0);
            if (math.mod(me.b_text,me.compass_dot_spread_deg*2) == 0) {
                me.compass_text[me.text_idx].setTranslation(me.b_dot,-4)
                                            .setText(math.periodic(0,360,me.b_text));
                me.text_idx += 1;
            }
            me.b_text += me.compass_dot_spread_deg;
            me.b_dot += me.compass_dot_spread_px;
        }
    },
    
    altitude_display: func() {
        # rotate line
        me.alt_line.setRotation(prop_io.altitude * me.alt_rotations_per_foot * 360 * D2R);
        # display text
        # display resolution is 20ft increments below 5000ft, and 50ft above
        if (prop_io.altitude <= 5000) {
            me.alt_text.setText(prop_io.altitude - math.mod(prop_io.altitude,20));
        } else {
            me.alt_text.setText(prop_io.altitude - math.mod(prop_io.altitude,50));
        }
    },
    
    ias_text_update: func() {
        me.ias_text.setText(sprintf("%i",prop_io.airspeed));
    },
        
    groundspeed_mach_text: func() {
        me.gs_m_output.setText( me.gs_m_mode ? sprintf("%i",prop_io.groundspeed) : sprintf("%0.2f",prop_io.mach));
    },
    
    groundspeed_mach_switch: func() {
        me.gs_m_mode = 1 - me.gs_m_mode;
        me.gs_m_text.setText(me.gs_m_mode ? "GS" : "M");
    },
    
    gmeter_display: func() {
    
        me.gmeter_center = prop_io.normalg;
        me.gmeter_offset = 0 - me.gmeter_spacing + ((((prop_io.normalg - 0.1) * 10) - math.floor(prop_io.normalg * 10)) / 10) * me.gmeter_spacing;
        
        me.gmeter_text[0].setTranslation(0,me.gmeter_offset);
        me.gmeter_text[0].setText(math.round((prop_io.normalg - 0.1) * 10) / 10);
        me.gmeter_text[1].setTranslation(0,me.gmeter_offset + me.gmeter_spacing);
        me.gmeter_text[1].setText(math.round(prop_io.normalg * 10) / 10);
        me.gmeter_text[2].setTranslation(0,me.gmeter_offset + me.gmeter_spacing * 2);
        me.gmeter_text[2].setText(math.round((prop_io.normalg + 0.1) * 10) / 10);

    },
    
    ###################################### state stuff to be worked in
    
    change_state: func(state) {
        if (state.main_func == nil) { return; }
        if (state.temp == 0) {
            me.cur_state = state;
            if (me.cur_end_func != nil) {
                #print('calling the end func');
                call(me.cur_end_func, nil, hud_ref);
            }
            me.cur_main_func = state.main_func;
            me.cur_init_func = state.init_func;
            me.cur_end_func = state.end_func;
            if (me.cur_init_func != nil) {
                #print('calling the init func');
                call(me.cur_init_func, nil, hud_ref);
            }
        } else if (state.temp == 1) {
            if (state.init_func != nil) {
                call(state.init_func, nil, hud_ref);
            }
            if (state.main_func != nil) {
                call(state.main_func, nil, hud_ref);
            }
            if (state.end_func != nil) {
                call(state.end_func, nil, hud_ref);
            }
        }
    },
    
    main_loop: func() {
        # check for electricity power
        if (me.cur_state != hud_state_off and prop_io.hud_power < 0.8) {
            me.change_state(hud_state_off);
        } elsif (me.cur_state == hud_state_off and prop_io.hud_power > 0.8) {
            me.change_state(hud_dev_mode);
        }
        if (me.cur_main_func != nil) {
            call(me.cur_main_func, nil, hud_ref );
        }
    },
    
};

hud_ref = HUD_SCREEN.new({"node": "HudCanvas"});

var state_arch = {
        main_func: nil,
        init_func: nil,
        end_func:  nil,
        temp:        0,
};

# main modes
# run the init once, loop the main, and then before the mode gets switched again it will run the end function
var hud_state_off = {parents: [state_arch], main_func: hud_ref.off_mode_update, init_func: hud_ref.off_mode_init};
var hud_dev_mode  = {parents: [state_arch], main_func: hud_ref.dev_mode_update, init_func: hud_ref.dev_mode_init};

# temps
# if temp == 1, it will only fire the init, main, and end functions once.
var hud_switch_gs_m = {parents: [state_arch], main_func: hud_ref.groundspeed_mach_switch, temp: 1};

hud_ref.change_state(hud_dev_mode);
