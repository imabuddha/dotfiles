-- jdm — customized awesome wnd mgr config

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- prevent hotkeys_popup from showing tmux keys
package.loaded["awful.hotkeys_popup.keys.tmux"] = {}

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local dpi   = require("beautiful.xresources").apply_dpi
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
naughty.config.icon_formats = {"png", "gif", "svg"}
naughty.config.icon_dirs = {
    "/usr/share/pixmaps/", 
    "/usr/share/icons/gnome/16x16/status/",
    "/usr/share/icons/gnome/16x16/devices/",
    "/usr/local/share/icons/hicolor/32x32/apps/"
}

local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- awesome-wm-widgets
local volume_widget = require("awesome-wm-widgets.experiments.volume.volume")
local weather_widget = require("awesome-wm-widgets.weather-widget.weather")
local logout_popup = require("awesome-wm-widgets.logout-popup-widget.logout-popup")
--local docker_widget = require("awesome-wm-widgets.docker-widget.docker")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), "default")
beautiful.init(theme_path)

-- lain widgets, utils, layouts lib
local lain  = require("lain")
local markup = lain.util.markup
local separators = lain.util.separators

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    --awful.layout.suit.floating,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
}
-- }}}


-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}


-- {{{ Wibar

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Separators
local arrow_left = separators.arrow_left
local arrow_right = separators.arrow_right

-- return a new widget that draws the middle of a powerline.
--  use with calls to arrow_left or arrow_right on each side.
--  if icon != nil it will appear to the left of widget.
local function pl_middle(icon, widget, bgcolor, left_padding, right_padding, buttons)
    local plm = wibox.container.background(
        wibox.container.margin(
            wibox.widget { icon, widget, layout = wibox.layout.align.horizontal },
            dpi(left_padding), dpi(right_padding)),
        bgcolor)

    if buttons then
        plm:buttons(buttons)
    end
    return plm
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Create a textclock widget
mytextclock = wibox.widget.textclock()
if beautiful.textclock_font then
    mytextclock.font = beautiful.textclock_font
end

-- Create a popup month-calendar
month_calendar = awful.widget.calendar_popup.month()
month_calendar:attach( mytextclock, "tr")

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- return widget "icon" + text markup string
local function wgt_markup(icon, text)
    return markup.fontfg(beautiful.font, beautiful.widget_icon_color, icon)
        .. markup.fontfg(beautiful.font, beautiful.widget_text_color, text)
end

-- CPU
local cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font, beautiful.widget_text_color, string.format("%02d%%", tonumber(cpu_now.usage))))
    end
})

-- Coretemp
local tempicon = wibox.widget.imagebox(beautiful.widget_temp)
local temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font, beautiful.widget_text_color,  math.floor( tonumber(coretemp_now) + 0.5 ) .. "°C "))
    end
})

-- Net
local netdowninfo = wibox.widget.textbox()
local netupinfo = wibox.widget.textbox()

-- NOTE: actually using this widget in the wibar doesn't work reliably!
--      as shown on the lain wiki it will error on awesome reload intermittently!
--      this is caused by it trying to set 'devices' when the widget is "read only" ???
--      My solution is to use separate textbox widgets for display in wibar.
local netinfo = lain.widget.net({
    settings = function()
        netupinfo:set_markup(wgt_markup(beautiful.widget_neticon,  string.format("%05.1f ", net_now.sent )))
        netdowninfo:set_markup(markup.fontfg(beautiful.font, beautiful.widget_text_color,  string.format(" %05.1f", tonumber(net_now.received))))
    end
})

-- MEM
local memicon = wibox.widget.imagebox(beautiful.widget_mem)
local memory = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font, beautiful.widget_text_color, string.format("%02d%% ", tonumber(mem_now.perc))))
    end
})

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- upgradable packages
local upgradable_cmd = 'bash -c "apt list --upgradable | wc -l"'
local function upgradable_update(widget, stdout)
    local upgradable_pkgs = tonumber(stdout)
    if upgradable_pkgs > 1 then
        widget:set_text(" 📦️ " .. (upgradable_pkgs-1) .. " ")
    else
        widget:set_text("")
    end
end

-- check for upgradable pkgs every hour
local upgradable, upgradable_timer = awful.widget.watch(upgradable_cmd, 3600, upgradable_update)

local upgradable_buttons = gears.table.join(
    awful.button({}, 1, function() -- open terminal with list of upgradable pkgs
        awful.spawn(terminal.." -e bash -c \"apt list --upgradable;bash\"", false)
    end),
    awful.button({}, 3, function() -- force widget text update
        upgradable_timer:again()
        awful.spawn.easy_async(upgradable_cmd, function(stdout)
            upgradable_update(upgradable, stdout)
        end)
    end)
)
upgradable:buttons(upgradable_buttons)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- buttons
local textclock_buttons = gears.table.join(
    awful.button({}, 3, function()
        awful.spawn("slashtime", false)
    end)
)
mytextclock:buttons(textclock_buttons)

local sysmon_buttons = gears.table.join(
    awful.button({}, 1, function()
        awful.spawn(terminal.." -e bpytop", false)
    end)
)

local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end)
                )


-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ " ❶ ", " ❷ ", " ❸ ", " ❹ ", " ❺ " }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    --[[
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    --]]

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        layout   = {
            layout  = wibox.layout.grid.horizontal
          },
        buttons = taglist_buttons,
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style    = {
            shape  = gears.shape.octogon,
        },
        layout   = {
            layout  = wibox.layout.fixed.horizontal
        },
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })


    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            upgradable,

            arrow_left(beautiful.bg_normal, beautiful.powerline_bg1),
            pl_middle(nil, volume_widget{ type = 'icon' }, beautiful.powerline_bg1, 4, 4),

            arrow_left(beautiful.powerline_bg1, beautiful.powerline_bg2),
            pl_middle(cpuicon, cpu.widget, beautiful.powerline_bg2, 0, 0, sysmon_buttons),
            pl_middle(tempicon, temp.widget, beautiful.powerline_bg2, 0, 0, sysmon_buttons),

            arrow_left(beautiful.powerline_bg2, beautiful.powerline_bg1),
            pl_middle(memicon, memory.widget, beautiful.powerline_bg1, 0, 0, sysmon_buttons),

            arrow_left(beautiful.powerline_bg1, beautiful.powerline_bg2),
            pl_middle(nil, netdowninfo, beautiful.powerline_bg2, 0, 0, sysmon_buttons),
            pl_middle(nil, netupinfo, beautiful.powerline_bg2, 0, 1, sysmon_buttons),

            arrow_left(beautiful.powerline_bg2, beautiful.powerline_bg1),
            pl_middle(nil,
                      weather_widget({
                                    api_key = '361b7e987933fab20873de4731f25d6c',
                                    coordinates = {32.0429045, 131.426049},
                                    show_hourly_forecast = true,
                                    show_daily_forecast = true,
                                    timeout = 600,
                                    }), 
                      beautiful.powerline_bg1, 4, 5),

            arrow_left(beautiful.powerline_bg1, "alpha"),
            pl_middle(nil, mytextclock, alpha, 0, 0),

            --s.mylayoutbox
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)--,
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- System
    awful.key({ "Control", "Mod1" }, "Delete", function () logout_popup.launch{
                                                                                bg_color = beautiful.bg_urgent,
                                                                                phrases = {},
                                                                                onlock = function() awful.spawn("xscreensaver-command -lock") end,
                                                                                onsuspend = function() end,
                                                                              } end,
              {description = "shutdown/reboot/logout", group = "awesome"}),
    awful.key({ "Control", "Mod1" }, "l", function () awful.spawn("xscreensaver-command -lock", false) end,
              {description = "lock screen", group = "awesome"}),

    -- On the fly useless gaps change
    awful.key({ modkey }, "=", function () lain.util.useless_gaps_resize(1) end,
              {description = "inc useless gaps", group = "layout"}),
    awful.key({ modkey }, "-", function () lain.util.useless_gaps_resize(-1) end,
              {description = "dec useless gaps", group = "layout"}),

    -- Screenshot
    awful.key({ }, "Print", function () awful.spawn("scrot '/home/pi/Pictures/ScreenGrabs/%F_%T_$wx$h.png'", false) end,
              {description = "full screenshot", group = "screenshot"}),
    awful.key({ "Shift" }, "Print", nil, function () awful.spawn("scrot -s '/home/pi/Pictures/ScreenGrabs/%F_%T_$wx$h.png'", false) end,
              {description = "select screenshot", group = "screenshot"}),
    awful.key({ "Mod1" }, "Print", function () awful.spawn("scrot -ub '/home/pi/Pictures/ScreenGrabs/%F_%T_$wx$h.png'", false) end,
              {description = "active window screenshot", group = "screenshot"}),

    -- Volume Keys
    awful.key({}, "XF86AudioLowerVolume", function () volume_widget:dec() end,
              {description = "lower volume", group = "media"}),
    awful.key({}, "XF86AudioRaiseVolume", function () volume_widget:inc() end,
              {description = "raise volume", group = "media"}),
    awful.key({}, "XF86AudioMute", function () volume_widget:toggle() end,
              {description = "toggle mute", group = "media"}),

    -- apps -jdm
    awful.key({ modkey }, "e", function () awful.spawn("mousepad", false) end,
              {description = "editor", group = "launcher"}),
    awful.key({ modkey }, "v", function () awful.spawn("gvim", false) end,
              {description = "gvim editor", group = "launcher"}),
    awful.key({ modkey }, "d", function () awful.spawn("deadbeef", false) end,
              {description = "deadbeef music player", group = "launcher"}),
    awful.key({ "Control", "Mod1" }, "h", function () awful.spawn(terminal.." -e htop", false) end,
              {description = "htop", group = "launcher"}),
    awful.key({ "Control", "Mod1" }, "f", function () awful.spawn("thunar", false) end,
              {description = "file manager", group = "launcher"}),
    awful.key({ "Control", "Mod1" }, "c", function () awful.spawn("/usr/share/code/code --no-sandbox --unity-launch", false) end,
              {description = "vs code", group = "launcher"}),
    awful.key({ "Control", "Mod1" }, "b", function () awful.spawn("chromium-browser", false) end,
              {description = "web browser", group = "launcher"}),
    awful.key({ "Control", "Mod1" }, "m", function () awful.spawn("chromium-browser --user-agent=\"Mozilla/5.0 (X11; CrOS armv7l 12371.89.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36\"", false) end,
              {description = "media web browser", group = "launcher"}),
    awful.key({ "Control", "Mod1" }, "p", function () awful.spawn("qpdfview --unique", false) end,
              {description = "pdf viewer", group = "launcher"}),
    awful.key({ modkey, "Mod1" }, "space", function () awful.spawn("splatmoji -s light type", false) end,
              {description = "emoji", group = "launcher"}),
    awful.key({ modkey }, "w", 
              function () awful.spawn("/usr/bin/chromium-browser --profile-directory=Default --app-id=jgeocpdicgmkeemopbanhokmhcgcflmi", 
                                      false) 
              end,
              {description = "twitter", group = "launcher"}),
    awful.key({ modkey }, "c", function () awful.spawn("galculator", false) end,
              {description = "calculator", group = "launcher"}),
    awful.key({ modkey }, "z", function () awful.spawn("slashtime", false) end,
              {description = "world time zones", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, }, "q",      function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "f",  awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen() end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
          "slashtime",
          "galculator"
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- DeaDBeeF always floating with titlebar [note must set title prefs in app]
    { rule = { name = "DeaDBeeF" 
      }, properties = { placement = awful.placement.top_right, floating = true, titlebars_enabled = true } 
    },
    
    -- twitter chromium "app"
    { rule = { name = "Twitter" 
      }, properties = { placement = awful.placement.top_right, maximized_vertical = true,  
                        dockable = true, type = "utility",
                        ontop = true, floating = true },
         callback = function(c)
            -- !!! this is a hack that will make the window actually dock as soon as the mouse is moved
            awful.mouse.client.move(c)
         end
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Get Awesome to respect xdg/autostart
awful.spawn.with_shell(
       'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
       'xrdb -merge <<< "awesome.started:true";' ..
       -- optionally, list each of your autostart commands, followed by ; inside single quotes, followed by ..
       'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_HOME/autostart"'
       )

-- set wallpaper using nitrogen
awful.spawn.with_shell("nitrogen --restore")

-- screensaver
awful.spawn.with_shell("xscreensaver -no-splash")
