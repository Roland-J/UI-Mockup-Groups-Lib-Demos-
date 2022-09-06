--[[Copyright © 2022, RolandJ
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright
	  notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright
	  notice, this list of conditions and the following disclaimer in the
	  documentation and/or other materials provided with the distribution.
	* Neither the name of RolandJ Groups nor the
	  names of its contributors may be used to endorse or promote products
	  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL RolandJ BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.version = '0.0.4'
_addon.name = 'UIMockup'
_addon.author = 'RolandJ'
_addon.commands = {'uimockup', 'mockup'}

require('luau')
local config = require('config')
local groups = require('rj_groups') -- IMPORTANT: import this into your windower/addons/libs folder
groups.debug_mode(true) -- NOTICE: makes bounds and anchors visible

--[[ Wiki Section ---------------------------------------------------------------------------------------
0. Groups & Their Elements: This library allows you to create groups of elements, specifically groups of
     images and texts objects. A group is comprised of its elements and its anchor. Its anchor is dict-
	 tated by its alignment. (see next point)
1. Alignment: This library supports vertical - top/center/bottom - and horizontal - left/center/right -
     alignment. Traditional elements like texts have a top-left ANCHOR, meaning that a pos 0/0 text has
	 and anchor of 0/0. With alignment, however, the anchor moves. So, a top.right aligned group's
	 anchor will be the pixel in the top-right corner of your screen. A center/center aligned group's
	 anchor will be the center of your screen. This allows your groups to find these dynamic anchor
	 locations effortlessly, without a lot of coding required on your part. To allow further positioning,
	 the alignment mechanism also supports x/y OFFSETS. A top/right aligned group with a -40/-20 offset
	 will appear with its anchor 40 pixels from the right of your screen and 20 pixels from the top of
	 your screen.
2. UI Scalar: This library supports UI scalars. Both the previously mentioned OFFSETS and your defined
     element sizes will be scaled with your current UI scalar. This means that for users with large 4k
	 monitors and a large x2.5 UI scalar, this lib's groups will grow to be 2.5x larger than normal, so
	 that they do not render at a miniscule size compared to your UI scalar. This also allows offsets to
	 keep pace with the vanilla UI's offsets, since the vanilla UI's offsets get scaled too BTW. This is
	 why this demo's vanilla_ui mockup's top-right anchor stays synced with the actual vanilla UI's top-
	 right corner, as both are scaling with your UI scalar!
3. Visuals: This library supports many default visuals! This means that you can easily add visuals to
     your elements. The code below demonstrates how to do so. The provided visuals are:
	     left_click_travel,   left_click_toggle,   left_click_bulge,   left_click_tint,
	     right_click_travel,  right_click_toggle,  right_click_bulge,  right_click_tint,
	     middle_click_travel, middle_click_toggle, middle_click_bulge, middle_click_tint,
	     scroll_zoom, hover_travel, hover_bulge, hover_tint, hover_arrow, hover_color
4. Zoom: As you may have noticed in the visuals, this library supports zooming in/out of a group via the
     mouse scroll wheel. The zoom feature provides three "focus" settings:
         1. No focus: The default focus, given when no specific focus is declared. In this mode, the
                 given group will grow outward from its anchor. A top/left aligned group will grow down-
				 wardand rightward, a center/center aligned group will grow in all directions, whilst a
				 bottom/right aligned group will grow upward/leftward.
		 2. Center focus: Regardless of the group's alignment, it will grow outward from its center. I
		         am expecting this to be the most popular zoom focus.
		 3. Cursor focus: Regardless of the group's alignment, it will grow outward from the cursor. This
		         would be useful for map UIs, for certain.
5. Events: Along with visuals, this library supports adding events to any element. See the below sample
     code for the syntax to use. This allows you to run your own function when an element is clicked,
	 released, hovered, or scrolled. With events, images and texts can easily become interactable!
6. Drag Sync: All the elements within a group are dragged together when any one of its elements is drag-
     ged! This allows you to create clusters of elements easily allow them to be both clickable and drag-
	 gable, without having to fuss with any complex drag logic!
7. Drag Bounds: This feature allows you to define optional bounds which groups cannot be dragged outside
     of! This will hopefully provide an intuitive and user-friendly way of helping keep the groups on-
	 screen, assuming that users wouldn't want to drag a group offscreen.
8. group Sync: This feature allows you to sync multiple groups together. When synced, all groups will
     A) zoom in/out together, B) drag together, and C) calculate their drag bounds together. This is use-
	 ful if you have multiple groups where one main element's buttons show/hide the other groups, similar
	 to this demo's vanilla_ui demo UI.
9. Config/Saving: This library automatically saves group positions and zoom levels. Any addon utilizing
     this library will therefore inherently support persistent user preferences regarding group position
	 and zoom! Hurray!
10. Auto-Hide: This library also supports auto-hide. This means that while zoning - both between zones and
     during login/logout - any groups that have auto-hide enabled will disappear when zoning out and re-
	 appear when zoning in.
BTW: Feel free to re-use my Button002-NeutralLight2.png asset.
------------------------------------------------------------------------------------------------------]]

------------------------------------------------------------------------------------
-- DEMO 1: Map UI Example (Loaded first for z-index reasons, so this is in the bg)
-- PURPOSES: 
--   1. Display the scroll zoom visual effect & how to register for it.
--   2. Shows that the mouse scroll zoom can be focused on the cursor.
--   3. Demonstrates that the auto_hide feature can be disabled.
------------------------------------------------------------------------------------
local function init_demo_1()
	map_ui = groups.new('Map UI', {
		visible     = true,
		scale_limit = {min = 0.5, max = 30},
		horizontal_align = 'center',
		vertical_align   = 'center',
		auto_hide   = false, --<-- PURPOSE 2
	})

	local map = map_ui:new_element('map', {
		class = 'images',
		name  = 'map',
		pos   = {x = 10, y = 100},
		size  = {400, 400},
		draggable = {right = true},
	})
	map:path(windower.addon_path .. 'data/FFXI-Atlas-Sanctuary-Zitah.jpg')
	map:fit(false)
	map_ui.register_visual(map, {'scroll_zoom', {percent=15, focus='cursor'}}) --<-- PURPOSE 1
end
init_demo_1()


------------------------------------------------------------------------------------
-- DEMO 2: Vanilla UI Mockup
-- PURPOSE: 
--   0. Show-off a potentially complex alignment. (top-RIGHT. top is easy, right is not)
--   1. Show a modularized UI made up of multiple synced groups.
--   2. Illustrate how synced groups operate during dragging. This sort of group, how-
--        ever, wouldn't normally be draggable. It is only so for the sake of #3.
--   3. Exhibit the drag bounds feature and how it factors in all the synced groups.
--   4. Display the default auto_hide default behavior: ON.
--   5. Demonstrate that groups can be hidden by default and shown on-demand.
--   6. Demonstrate the hover_color, hover_arrow, left_click_travel, and left_click_bulge
--        visual effects, and how to register for them.
--   7. Reveal how center-focused scroll zoom behaves and even honors drag bounds.
--   8. Discloses how to integrate click event args with the click_toggle visuals.
--   9. Teaches how to combine alignment (top/right) with offset to imitate a vanilla
--        ui element's placement precisely, making slick UI replacements easier.
------------------------------------------------------------------------------------
function init_demo_2()
	local labels = {'Status','Equipment','Magic','Items','Synthesis','Abilities','Party','Trade','Search','Linkshell','Region Info','Map'}
	local colors = {
		blue   = function() return 160, 160, 220 end,
		orange = function() return 180, 100,   0 end,
	}
	local d = { -- button defaults (these get scaled, according to your UI scalar, by the groups lib)
		pad  = {width = 10, height = 4}, btn  = {width = 76,  height = 14},
		shdw = {width = 2,  height = 1}, sub  = {width = 250, height = 300},
		top_left = {x = 0, y = 0}, font_size = 9, gap  = {width = 1},
	}
	d.main_ui = {width = (d.pad.width * 2) + d.btn.width + d.shdw.width, height = (d.btn.height * #labels) + (d.pad.height * 2), left = d.top_left.x + d.gap.width + d.sub.width}
	
	test_fn = function(visible)
		visible = visible or false
		local status = groups.name_lookup('Status Sidecar UI')
		status:visible(visible)
	end
	
	local function on_click(m, release)
		if release then
			-- TOGGLE ON LOGIC
			if m.toggle_state then
				log('Run your toggle-on code for %s here.':format(m.name))
			-- TOGGLE OFF LOGIC
			elseif m.toggle_state ~= nil then
				log('Run your toggle-off code for %s here':format(m.name))
			-- CONSTANT LOGIC
			else
				log('Run your constant on-click code for %s here':format(m.name))
				for _, label in ipairs(labels) do
					local sidecar = groups.name_lookup(label .. ' Sidecar UI')
					local button = groups.name_lookup('Vanilla UI Mockup_images_' .. label)
					local visible = (label == m.name and not sidecar.m.visible) and true or false
					sidecar:visible(visible)
					local color = visible and colors.orange or colors.blue
					button.m.color = {color()}
					button:color(color())
				end
			end
		end
	end

	function on_scroll(data)
		log('Run your scroll-%s code for %s here':format(data.mode,data.m.name))
		local new_val = tonumber(data.m.embeds.Scroll.t:text()) + (data.mode == 'up' and 1 or -1)
		data.m.embeds.Scroll.t:text(tostring(new_val))
	end
	
	vanilla_ui = groups.new('Vanilla UI Mockup', { --this gets synced to sidecar, so some of these propagate to sidecar (not visible)
		drag_bounds = {top=0, left=0, bottom=0, right=0}, -- keeps group from dragging offscreen
		visible     = true, --this group, and its elements, will now appear by default
		scale_limit = {min = 0.75, max = 3}, --bounds for the scalar on zoom/resize, scales to user UI scalar
		horizontal_align = 'right', -- group will start on right border(0,0) & grow down/left (vertical align will default to top)
		offset      = {x = -12, y = 35}, --group will start -12/35 away from ITS 0,0 (based on its alignment), scaled by UI scalar.
		-- Since this group is top/right aligned, its 0,0 - or its anchor position - will be ui_res.x/0
		--auto_hide: since this property was not defined, it will default to true!
	})
	
	-- Vanilla UI group - Border
	local border = vanilla_ui:new_element('Border', {
		class     = 'images',
		name      = 'Border',
		pos       = {x = d.main_ui.left, y = d.top_left.y},
		size      = {d.main_ui.width, d.main_ui.height}, -- this gets scaled
		--size    = {x_percent = 30, y_percent = 20}, -- IMPORTANT: Is there demand for this? I could see some UIs needing this
		color     = {200, 200, 255},
		draggable = {right = true}, --this shouldn't be draggable, but I want you to be able to see this interact with drag bounds
	})

	-- Container group - Container
	local container = vanilla_ui:new_embedded_element(border, 'Container', {
		class     = 'images',
		name      = 'Container',
		pos       = {x = d.main_ui.left, y = d.top_left.y + 1},
		size      = {d.main_ui.width, d.main_ui.height - 2},
		color     = {0, 0, 70},
	})
	vanilla_ui.register_visual(container, {'scroll_zoom', {percent=10, focus='center'}})

	-- Container group - Commands Label
	local cntn_label = vanilla_ui:new_embedded_element(border, 'Commands', {
		class      = 'texts',
		name       = 'Commands Label',
		pos        = {x = d.main_ui.left + 22, y = d.top_left.y - 5},
		size       = 7,
		stroke_width = 0.75,
	})
	cntn_label:bold(true)
	cntn_label:italic(true)
	cntn_label:bg_visible(false)

	-- Vanilla UI group - Standard Buttons
	for i, label in ipairs(labels) do
		-- Button group - Button 1
		local btn1 = vanilla_ui:new_element(label, {
			class     = 'images',
			name      = label,
			pos       = {x = d.main_ui.left + d.pad.width + d.shdw.width, y = d.top_left.y + d.pad.height + (d.btn.height * (i - 1))},
			size      = {d.btn.width, d.btn.height},
			color     = {colors.blue()},
		})
		btn1:path(windower.addon_path .. 'data/Button002-NeutralLight2.png')
		btn1:fit(false)
		vanilla_ui.register_visual(btn1, {'hover_color', colors.orange}, {'hover_arrow', 'left'}, {'left_click_travel', {x=0.5, y=0.5}}, {'left_click_bulge', {x=1, y=1}})
		vanilla_ui.register_event(btn1, {'left_click', on_click})

		-- Button group - Button 1 - Text 1
		local txt1 = vanilla_ui:new_embedded_element(btn1, label, { --integrates this element with btn1's visual effects
			class        = 'texts',
			name         = label,
			pos          = {x = d.main_ui.left + d.pad.width + 5, y = d.top_left.y + d.pad.height - 1 + (d.btn.height * (i - 1))},
			size         = d.font_size,
			bg_visible   = false,
			stroke_width = 0.5,
		})
		txt1:italic(true)
		txt1:bold(true)
	end
	
	for i, label in ipairs(labels) do
		sidecar_ui = vanilla_ui:new_synced_group(label .. ' Sidecar UI') -- NOTE: this group and vanilla_ui will now drag/resize together!
		-- NOTE2: Since we didn't define visibility, it will default to false (invisible/hidden)
		
		-- Sidecar UI group - Sidecar Border
		local border = sidecar_ui:new_element('Sidecar Border', {
			class     = 'images',
			name      = label .. ' Sidecar Border',
			pos       = {x = d.top_left.x, y = d.top_left.y},
			size      = {d.sub.width, d.sub.height},
			color     = {200, 200, 255},
			draggable = {right = true},
		})

		-- Sidecar UI group - Sidecar Container
		local container = sidecar_ui:new_embedded_element(border, 'Sidecar Container', {
			class     = 'images',
			name      = label .. ' Sidecar Container',
			pos       = {x = d.top_left.x, y = d.top_left.y + 1},
			size      = {d.sub.width, d.sub.height - 2},
			color     = {0, 0, 70},
		})
		sidecar_ui.register_visual(container, {'scroll_zoom', {percent=10, focus='center'}})

		-- Sidecar UI group - Commands Label
		local cntn_label = sidecar_ui:new_embedded_element(border, label, {
			class      = 'texts',
			name       = label .. ' Sidecar Label',
			pos        = {x = d.top_left.x + 5, y = d.top_left.y - 3.5},
			size       = 7,
			bg_visible = false,
			stroke_width = 1,
		})
		cntn_label:bold(true)
		cntn_label:italic(true)
	end
end
init_demo_2()


------------------------------------------------------------------------------------
-- DEMO 3: Clustered Buttons UI
-- PURPOSE:
--    1. Show a much more simple UI made up of a few buttons.
--    2. Show how to register for and listen to scroll events for easy var changing.
--    3. Display the hover_tint, hover_bugle, hover_travel, click_tint, and
--        click_color visual effects and registration.
--    4. To showcase a dual clickable/scrollable button control design.
--    5. To illustrate the default value support of the click_toggle visuals. By de-
--        fining the default as the saved preference, these buttons can be initialized
--        in a toggle state matching the user's saved setting.
------------------------------------------------------------------------------------
local function init_demo_3()
	local defaults3 = {toggle_state=false, scroll_value=0}
	settings3 = config.load('data/demo_3_data.xml', defaults3)
	config.save(settings3)
	
	local labels = {'Standard','Toggle','Scroll'}
	local colors = {
		blue   = (function() return 160, 160, 220 end),
		orange = (function() return 180, 100,   0 end),
	}
	local toggle_config = {
		default = settings3.toggle_state,
		colors  = {
			[true]  = {colors.orange()},
			[false] = {colors.blue()}
		},
	}
	local d = { -- button defaults
		pad  = {width = 10, height = 6}, btn      = {width = 140,  height = 30},
		shdw = {width = 2,  height = 1}, top_left = {x = 0, y = 0}, 
		font_size = 18, gap  = {width = 1},
	}
	d.ui = {width = (d.pad.width * 2) + d.btn.width + d.shdw.width, height = (d.btn.height * #labels) + (d.pad.height * 2)}

	local function on_click(m, release)
		if release then
			-- TOGGLE ON LOGIC
			if m.toggle_state then --NOTICE: This is how to integrate your events with the toggle visual!
				log('Run your toggle-on code for %s here.':format(m.name))
				m.embeds.Toggle_value.t:text('On') -- just dumb dummy logic for the demo
				settings3.toggle_state = true
				config.save(settings3)
			-- TOGGLE OFF LOGIC
			elseif m.toggle_state ~= nil then --NOTICE: This is how to integrate your events with the toggle visual!
				log('Run your toggle-off code for %s here':format(m.name))
				m.embeds.Toggle_value.t:text('Off') -- just dumb dummy logic for the demo
				settings3.toggle_state = false
				config.save(settings3)
			-- CONSTANT LOGIC
			else
				log('Run your constant on-click code for %s here':format(m.name))
				if m.embeds.Scroll_value then
					local old = m.embeds.Scroll_value.t:text()
					settings3.scroll_value = old + 5 > 20 and 0 or old + 5
					config.save(settings3)
					m.embeds.Scroll_value.t:text(tostring(settings3.scroll_value))
				end
			end
		end
	end

	function on_scroll(m, mode)
		log('Run your scroll-%s code for %s here':format(mode,m.name))
		settings3.scroll_value = tonumber(m.embeds.Scroll_value.t:text()) + (mode == 'up' and 1 or -1)
		config.save(settings3)
		m.embeds.Scroll_value.t:text(tostring(settings3.scroll_value))
	end
	
	-- Cluster UI
	cluster_ui = groups.new('Cluster UI Mockup', {
		drag_bounds = {top=0, left=0, bottom=0, right=0}, -- keeps group from dragging offscreen
		visible     = true, --this group, and its elements, will now appear by default
		scale_limit = {min = 0.75, max = 3}, --bounds for the scalar on zoom/resize, scales to user UI scalar
		offset      = {x = 15, y = 70}, --group will start 100/100 away from ITS 0,0, scaled by UI scalar.
		-- Since this group has no defined horizontal/vertical alignment, it defaults to left/top and so its 0/0 is 0/0.
	})
	
	
	-- Cluster UI group - Border
	local border = cluster_ui:new_element('Cluster Border', {
		class     = 'images',
		name      = 'Sidecar Border',
		pos       = {x = d.top_left.x, y = d.top_left.y},
		draggable = {right = true},
		size      = {d.ui.width, d.ui.height},
		color     = {200, 200, 255},
	})
	cluster_ui.register_visual(border, {'scroll_zoom', {percent=10, focus='center'}})

	-- Vanilla UI group - Sidecar Container
	local container = cluster_ui:new_embedded_element(border, 'Cluster Container', {
		class     = 'images',
		name      = 'Sidecar Container',
		pos       = {x = d.top_left.x, y = d.top_left.y + 1},
		size      = {d.ui.width, d.ui.height - 2},
		color     = {0, 0, 70},
	})

	-- Container group - Commands Label
	local cntn_label = cluster_ui:new_embedded_element(border, 'Commands', {
		class      = 'texts',
		name       = 'Cluster Label',
		pos        = {x = d.top_left.x + 45, y = d.top_left.y - 8},
		size       = 11,
		bg_visible = false,
		stroke_width = 0.75,
	})
	cntn_label:bold(true)
	cntn_label:italic(true)
	
	for i, label in ipairs(labels) do
		-- Button group - Button 1
		local btn1 = cluster_ui:new_element(label .. ' Button', {
			class     = 'images',
			name      = label..'_button',
			pos       = {x = d.top_left.x + d.pad.width + d.shdw.width, y = d.top_left.y + d.pad.height + (d.btn.height * (i - 1))},
			draggable = {right = true},
			size      = {d.btn.width, d.btn.height},
			color     = {colors.blue()},
		})
		btn1:path(windower.addon_path .. 'data/Button002-NeutralLight2.png')
		btn1:fit(false)
		cluster_ui.register_visual(btn1, {'hover_tint', -30}, {'hover_travel', {x = 1, y = 0.75}}, {'hover_bulge', {x = 2, y = 1.5}}, {'click_tint', -20})
		if label == 'Toggle' then cluster_ui.register_visual(btn1, {'left_click_toggle', toggle_config})
		elseif label == 'Scroll' then cluster_ui.register_event(btn1, {'scroll', on_scroll})
		else cluster_ui.register_visual(btn1, {'left_click_color', colors.orange}) end
		cluster_ui.register_event(btn1, {'left_click', on_click})

		-- Button group - Button 1 - Text 1
		local txt1 = cluster_ui:new_embedded_element(btn1, label, { --integrates this element with btn1's visual effects
			class        = 'texts',
			name         = label..'_label',
			pos          = {x = d.top_left.x + d.pad.width + 6, y = d.top_left.y + d.pad.height + (d.btn.height * (i - 1))},
			size         = d.font_size,
			bg_visible   = false,
			stroke_width = 1,
		})
		txt1:italic(true)
		txt1:bold(true)

		-- Button group - Button 1 - Text 1
		local tgl_map = {[true]='On', [false]='Off'}[settings3.toggle_state]
		local text  = {Toggle=tgl_map, Scroll=tostring(settings3.scroll_value), Standard=''}[label]
		local x_mod = {Toggle=95,      Scroll=95,                               Standard=0}[label]
		local txt2 = cluster_ui:new_embedded_element(btn1, text, { --integrates this element with btn1's visual effects
			class        = 'texts',
			name         = label..'_value',
			pos          = {x = d.top_left.x + d.pad.width + x_mod, y = d.top_left.y + d.pad.height + (d.btn.height * (i - 1))},
			size         = d.font_size,
			bg_visible   = false,
			stroke_width = 1,
		})
		txt2:italic(true)
		txt2:bold(true)
	end
end
init_demo_3()


------------------------------------------------------------------------------------
-- DEMO 4: Advanced Text Box UI Mockup
-- PURPOSE: Show how simple text boxes can easily become interactable.
-- NOTEWORTHY:
--     1. The active/min/max settings are all user preferences/persist on addon reload.
--     2. The scroll has no focus, so this element grows outward from its anchor's x/y pos.
--     3. Demonstrates that a slightly negative drag bounds allows clipping text padding.
------------------------------------------------------------------------------------
function init_demo_4()
	local defaults4 = {active=false, min=0, max=10}
	settings4 = config.load('data/demo_4_data.xml', defaults4)
	config.save(settings4)
	
	local active_map       = {[true]='  On  ',    [false]='  Off  '}
	local active_color_map = {[true]={0, 255, 0}, [false]={255, 0, 0}}
	local function on_click(m, release)
		if release then
			settings4.active = not settings4.active
			config.save(settings4)
			m.t:text(active_map[settings4.active])
			m.t:color(table.unpack(active_color_map[settings4.active]))
		end
	end
	local function text_scroll(m, mode)
		settings4[m.name] = tonumber(m.t:text()) + (mode == 'up' and 1 or -1)
		config.save(settings4)
		m.t:text('  ' .. settings4[m.name] .. '  ')
	end

	text_ui = groups.new('Text UI', {
		visible      = true,
		drag_bounds  = {top=-0.5, left=-1, bottom=-0.5, right=-1}, --allow clipping some text padding
		horizontal_align = 'right',
		vertical_align   = 'bottom',
	})

	local bg = text_ui:new_element('bg', {
		class = 'images',
		name  = 'bg',
		pos   = {x = 0, y = 0},
		size  = {154, 12},
		color = {0, 0, 0},
		draggable = {right = true},
	})
	text_ui.register_visual(bg, {'scroll_zoom', {percent=10}})

	local active_hdr = text_ui:new_element('Active:', {
		class     = 'texts',
		name      = 'active_hdr',
		pos       = {x = 10, y = 0},
		size      = 7,
	})
	active_hdr:bold(true)

	local active = text_ui:new_element(active_map[settings4.active], { --extra spaces to absorb events, rather than :pad, as that inflates height
		class     = 'texts',
		name      = 'active',
		pos       = {x = 39, y = 0},
		size      = 7,
		color     = active_color_map[settings4.active],
	})
	active:bold(true)
	active:bg_visible(false) --hide the bg of the added spaces
	text_ui.register_event(active, {'left_click', on_click})

	local minimum_hdr = text_ui:new_element('Min:         ', {
		class     = 'texts',
		name      = 'minimum_hdr',
		pos       = {x = 70, y = 0},
		size      = 7,
	})
	minimum_hdr:bold(true)

	local minimum = text_ui:new_element('  '..settings4.min..'  ', { --extra spaces to absorb events, rather than :pad, as that inflates height
		class     = 'texts',
		name      = 'min',
		pos       = {x = 87, y = 0},
		size      = 7,
		color     = {255, 255, 0},
	})
	minimum:bold(true)
	minimum:bg_visible(false) --hide the bg of the added spaces
	text_ui.register_event(minimum, {'scroll', text_scroll})

	local maximum_hdr = text_ui:new_element('Max:', {
		class     = 'texts',
		name      = 'maximum_hdr',
		pos       = {x = 109, y = 0},
		size      = 7,
	})
	maximum_hdr:bold(true)

	local maximum = text_ui:new_element('  '..settings4.max..'  ', { --extra spaces to absorb events, rather than :pad, as that inflates height
		class     = 'texts',
		name      = 'max',
		pos       = {x = 128, y = 0},
		size      = 7,
		color     = {255, 255, 0},
	})
	maximum:bold(true)
	maximum:bg_visible(false) --hide the bg of the added spaces
	text_ui.register_event(maximum, {'scroll', text_scroll})
end
init_demo_4()


------------------------------------------------------------------------------------
-- DEMO 5: Alignment Example
-- PURPOSE: 
--     1. Shows effortless support for a potentially complex alignment. (top/center+offset)
------------------------------------------------------------------------------------
function init_demo_5()
	map_ui = groups.new('Hotbar UI', {
		visible     = true,
		scale_limit = {min = 0.5, max = 30},
		horizontal_align = 'center',
		vertical_align   = 'top',
		offset      = {x = 0, y = 41},
		auto_hide   = false,
	})

	local map = map_ui:new_element('FFXIV Hotbar', {
		class = 'texts',
		name  = 'FFXIV Hotbar',
		pos   = {x = 10, y = 100},
		size  = 70,
	})
end
init_demo_5()


windower.add_to_chat(207, '[UIMockup] Loading RolandJ\'s UIMockup, a simple showcase of his rj_groups.lua library\'s capabilities...')
log('NOTE: Be sure to take a look at this addon\'s .lua file for a short wiki section written for addon authors!')

windower.register_event('addon command', function(...)
	local cmd = T{...}[1] and T{...} or T{'help'}
	if S{'eval','exec'}[cmd[1]:lower()] then
		windower.add_to_chat(207, '[EVALUATE] Evaluating "' .. cmd:slice(2):concat(' ') .. '"...')
		assert(loadstring(cmd:slice(2):concat(' ')), 'Eval error, check syntax: ' .. cmd:slice(2):concat(' '))()
		windower.add_to_chat(207, '[EVALUATE FINISHED] Processing complete.')
	end
end)