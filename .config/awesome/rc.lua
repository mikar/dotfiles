--- AwesomeWM 3.5.2 rc.lua ---
-- =====================================================================
-- {{{ s_libs
-- =====================================================================
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local drop      = require("scratchdrop")
local lain      = require("lain")
-- }}}

-- =====================================================================
-- {{{ s_error
-- =====================================================================
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- =====================================================================
-- {{{ s_autostart
-- =====================================================================
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

run_once("urxvtd")
run_once("unclutter -root")
-- }}}

-- =====================================================================
-- {{{ s_vars
-- =====================================================================
-- Apps
terminal   = "urxvt" or "xterm"
editor     = os.getenv("EDITOR") or "vim" or "vi"
editor_cmd = terminal .. " -e " .. editor
gui_editor = "gvim"
browser    = "firefox"
mail       = "thunderbird"
graphics   = "gimp"

-- Env
home       = os.getenv("HOME")
config     = awful.util.getdir("config")
hostname   = io.lines("/proc/sys/kernel/hostname")()

-- Appearance
barheight   = 20
borderwidth = 0

-- Widgets
weather_city = 2857807 -- Find out via http://openweathermap.org/find

-- Lain
lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol    = 1

-- Shortcuts
exec       = awful.util.spawn
sexec      = awful.util.spawn_with_shell
altkey     = "Mod1"
modkey     = "Mod4"
k_m        = { modkey }
k_ms       = { modkey, "Shift" }
k_mc       = { modkey, "Control" }
k_mcs      = { modkey, "Control", "Shift" }
k_a        = { altkey }
k_ac       = { altkey, "Control" }
k_as       = { altkey, "Shift" }
k_acs      = { altkey, "Control", "Shift" }
k_am       = { altkey, modkey }
k_ams      = { altkey, modkey, "Shift" }
-- }}}

-- =====================================================================
-- {{{ s_theme
-- =====================================================================
shared_themes_dir = "/usr/share/awesome/themes/"
themes_dir        = config .. "/themes"
theme             = "/multicolor/theme.lua"

if hostname == "htpc" then
    theme = "/rainbow/theme.lua"
end

if not awful.util.file_readable(themes_dir..theme) then
    themes_dir  = sharedthemes
end
beautiful.init(themes_dir..theme)

-- }}}

-- =====================================================================
-- {{{ s_wallpaper
-- =====================================================================
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- =====================================================================
-- {{{ s_tags
-- =====================================================================
local layouts = {
    awful.layout.suit.tile,             --1
    awful.layout.suit.tile.left,        --2
    awful.layout.suit.tile.top,         --3
    awful.layout.suit.fair.horizontal,  --4
    awful.layout.suit.max,              --5
    lain.layout.uselesstile,            --6
    lain.layout.uselessfair,            --7
    lain.layout.centerwork,             --8
    awful.layout.suit.floating,         --9
    --~ awful.layout.suit.tile.bottom,
    --~ awful.layout.suit.fair,
    --~ awful.layout.suit.spiral,
    --~ awful.layout.suit.spiral.dwindle,
    --~ lain.layout.centerfair,
    --~ lain.layout.cascade,
    --~ lain.layout.cascadetile,
    --~ lain.layout.centerfair,
    --~ lain.layout.centerhwork,
    --~ lain.layout.termfair,
    --~ lain.layout.uselessfair,
    --~ lain.layout.uselesspiral,
    --~ lain.layout.uselesstile,
}
tags = {
    names = { "web", "dev", "irc", "vlc", "docs", "play" },
    --names = { "♏", "♐", "⌘", "☊", "♓", "⌥", "♒" },
    layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[8], layouts[9] }
}
for s = 1, screen.count() do
-- Each screen has its own tag table.
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- =====================================================================
-- {{{ s_menu
-- =====================================================================
awesome_menu = {
    { "open terminal", terminal },
    { "edit config", editor_cmd .. " " .. config .. "/rc.lua"},
    { "run", function() mypromptbox[mouse.screen]:run() end },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}
generated_menu = require("menugen").build_menu()
mymainmenu = awful.menu({
    items = {
        { "awesome", awesome_menu },
        { "apps", generated_menu }
    }
})

-- Instead of using separate submenus like above you can also simply
-- insert the awesome_menu into the generated menu.
--~ table.insert(generated_menu, 1, { "awesome", awesome_menu })
--~ mymainmenu = awful.menu({ items = generated_menu })
-- }}}

-- =====================================================================
-- {{{ s_widgets
-- =====================================================================
markup = lain.util.markup

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
--mytextclock = awful.widget.textclock(markup("#7788af", "%A %d %B ") .. markup("#343639", ">") .. markup("#de5e1e", " %H:%M "))
mytextclock = lain.widgets.abase({
    timeout  = 60,
    cmd      = "date +'%A %d %B %R'",
    settings = function()
        local t_output = ""
        local o_it = string.gmatch(output, "%S+")

        for i=1,3 do t_output = t_output .. " " .. o_it(i) end

        widget:set_markup(markup("#7788af", t_output) .. markup("#343639", " > ") .. markup("#de5e1e", o_it(1)) .. " ")
    end
})

-- Calendar
lain.widgets.calendar:attach( mytextclock, { font_size = 10, followmouse = true } )

-- Weather
weathericon = wibox.widget.imagebox(beautiful.widget_weather)
myweather = lain.widgets.weather({
    city_id = weather_city,
    settings = function()
        descr = weather_now["weather"][1]["description"]:lower()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(markup("#eca4c4", descr .. " @ " .. units .. "°C "))
    end
})

-- Filesystem
fsicon = wibox.widget.imagebox(beautiful.widget_fs)
fswidget = lain.widgets.fs({
    settings  = function()
        widget:set_markup(markup("#80d9d8", fs_now.used .. "% "))
    end
})

-- CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
    end
})

-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
    settings = function()
        widget:set_markup(markup("#f1af5f", coretemp_now .. "°C "))
    end
})

-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_batt)
batwidget = lain.widgets.bat({
    settings = function()
        if bat_now.perc == "N/A" then
            perc = "AC "
        else
            perc = bat_now.perc .. "% "
        end
        widget:set_text(perc)
    end
})

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
        end

        widget:set_markup(markup("#7493d2", volume_now.level .. "% "))
    end
})

-- Net
netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
--netdownicon.align = "middle"
netdowninfo = wibox.widget.textbox()
netupicon = wibox.widget.imagebox(beautiful.widget_netup)
--netupicon.align = "middle"
netupinfo = lain.widgets.net({
    settings = function()
        if iface ~= "network off" and
           string.match(myweather._layout.text, "N/A")
        then
            myweather.update()
        end

        widget:set_markup(markup("#e54c62", net_now.sent .. " "))
        netdowninfo:set_markup(markup("#87af5f", net_now.received .. " "))
    end
})

-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
    settings = function()
        widget:set_markup(markup("#e0da37", mem_now.used .. "M "))
    end
})

-- Spacer
spacer = wibox.widget.textbox(" ")
-- }}}

-- =====================================================================
-- {{{ s_wibox
-- =====================================================================
-- Create a wibox for each screen and add it
mywibox = {}
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button(k_m, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button(k_m, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do

    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()


    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                            awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                            awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the upper wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 20 })
    --border_width = 0, height =  20 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    --right_layout:add(mailicon)
    --right_layout:add(mailwidget)
    right_layout:add(netdownicon)
    right_layout:add(netdowninfo)
    right_layout:add(netupicon)
    right_layout:add(netupinfo)
    right_layout:add(volicon)
    right_layout:add(volumewidget)
    right_layout:add(memicon)
    right_layout:add(memwidget)
    right_layout:add(cpuicon)
    right_layout:add(cpuwidget)
    right_layout:add(fsicon)
    right_layout:add(fswidget)
    right_layout:add(weathericon)
    right_layout:add(myweather)
    right_layout:add(tempicon)
    right_layout:add(tempwidget)
    right_layout:add(baticon)
    right_layout:add(batwidget)
    right_layout:add(clockicon)
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    --layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

    -- Create the bottom wibox
    mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 20 })
    --mybottomwibox[s].visible = false

    -- Widgets that are aligned to the bottom left
    bottom_left_layout = wibox.layout.fixed.horizontal()

    -- Widgets that are aligned to the bottom right
    bottom_right_layout = wibox.layout.fixed.horizontal()
    bottom_right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(bottom_left_layout)
    bottom_layout:set_middle(mytasklist[s])
    bottom_layout:set_right(bottom_right_layout)
    mybottomwibox[s]:set_widget(bottom_layout)
end
-- }}}

-- =====================================================================
-- {{{ s_mouse_bindings
-- =====================================================================
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- =====================================================================
-- {{{ s_key_bindings
-- =====================================================================
globalkeys = awful.util.table.join(
    -- Tag browsing
    awful.key(k_m, "Left",   awful.tag.viewprev       ),
    awful.key(k_m, "Right",  awful.tag.viewnext       ),
    awful.key(k_m, "Escape", awful.tag.history.restore),

    -- By direction client focus
    awful.key(k_m, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key(k_m, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key(k_m, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key(k_m, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key(k_m, "w",
        function ()
            mymainmenu:show({ keygrabber = true })
        end),

    -- Show/Hide Wibox
    awful.key(k_m, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        mybottomwibox[mouse.screen].visible = not mybottomwibox[mouse.screen].visible
    end),

    -- Layout manipulation
    awful.key(k_ms, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key(k_ms, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key(k_mc, "j", function () awful.screen.focus_relative( 1) end),
    awful.key(k_mc, "k", function () awful.screen.focus_relative(-1) end),
    awful.key(k_m, "u", awful.client.urgent.jumpto),
    awful.key(k_m, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key(k_as, "l",      function () awful.tag.incmwfact( 0.05)     end),
    awful.key(k_as, "h",      function () awful.tag.incmwfact(-0.05)     end),
    awful.key(k_ms, "l",      function () awful.tag.incnmaster(-1)       end),
    awful.key(k_ms, "h",      function () awful.tag.incnmaster( 1)       end),
    awful.key(k_mc, "l",      function () awful.tag.incncol(-1)          end),
    awful.key(k_mc, "h",      function () awful.tag.incncol( 1)          end),
    awful.key(k_m, "space",  function () awful.layout.inc(layouts,  1)  end),
    awful.key(k_ms, "space",  function () awful.layout.inc(layouts, -1)  end),
    awful.key(k_mc, "n",      awful.client.restore),

    -- Standard program
    awful.key(k_m, "Return", function () awful.util.spawn(terminal .. " -e tmux") end),
    awful.key(k_mc, "r",      awesome.restart),
    awful.key(k_ms, "q",      awesome.quit),

    -- Dropdown terminal
    awful.key(k_m, "a",      function () drop(terminal) end),

    -- Copy to clipboard
    awful.key(k_m, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key(k_m, "q", function () awful.util.spawn(browser) end),
    awful.key(k_m, "s", function () awful.util.spawn(gui_editor) end),
    awful.key(k_m, "g", function () awful.util.spawn(graphics) end),

    -- Prompt
    awful.key(k_m, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key(k_m, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key(k_m, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key(k_ms, "c",      function (c) c:kill()                         end),
    awful.key(k_mc, "space",  awful.client.floating.toggle                     ),
    awful.key(k_mc, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key(k_m, "o",      awful.client.movetoscreen                        ),
    awful.key(k_m, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key(k_m, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key(k_m, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key(k_m, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key(k_mc, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key(k_ms, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key(k_mcs, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button(k_m, 1, awful.mouse.client.move),
    awful.button(k_m, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false
                   },
        -- Start windows as slave
        callback = awful.client.setslave
    },
    { rule = { class = "URxvt" },
          properties = { opacity = 0.99 } },

    { rule = { class = "MPlayer" },
          properties = { floating = true } },

    { rule = { class = "Dwb" },
          properties = { tag = tags[1][1] } },

    { rule = { class = "Iron" },
          properties = { tag = tags[1][1] } },

    { rule = { instance = "plugin-container" },
          properties = { tag = tags[1][1] } },

      { rule = { class = "Gimp" },
            properties = { tag = tags[1][4] } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized_horizontal = true,
                         maximized_vertical = true } },
}
-- }}}

-- {{{ Signals
-- signal function to execute when a new client appears.
local sloppyfocus_last = {c=nil}
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    client.connect_signal("mouse::enter", function(c)
         if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
             -- Skip focusing the client if the mouse wasn't moved.
             if c ~= sloppyfocus_last.c then
                 client.focus = c
                 sloppyfocus_last.c = c
             end
         end
     end)

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- the title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c,{size=16}):set_widget(layout)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
                -- No borders with only one humanly visible client
                if layout == "max" then
                    c.border_width = 0
                elseif awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width
                elseif #clients == 1 then
                    clients[1].border_width = 0
                    if layout ~= "max" then
                        awful.client.moveresize(0, 0, 2, 0, clients[1])
                    end
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
      end)
end
-- }}}
