# UI-Mockup-Groups-Lib-Demos-
A collection of demos that illustrate how to use my groups library and shows off its capabilities.


### IMPORTANT
You must download **rj_groups.lua** at [my "Groups Library" repository](https://github.com/Roland-J/Groups-Library/blob/main/rj_groups.lua) and place it in your **windower/addons/libs** folder. This demo requires it as a dependency.


#### Wiki Section (All features can be found mocked up in this repository.)
1. **Groups & Their Elements:** This library allows you to create groups of elements, specifically groups of images and texts objects. A group is comprised of its elements and its anchor. Its anchor is dicttated by its alignment. (see next point)
2. **Alignment:** This library supports vertical - top/center/bottom - and horizontal - left/center/right - alignment. Traditional elements like texts have a top-left ANCHOR, meaning that a pos 0/0 text has and anchor of 0/0. With alignment, however, the anchor moves. So, a top.right aligned group's anchor will be the pixel in the top-right corner of your screen. A center/center aligned group's anchor will be the center of your screen. This allows your groups to find these dynamic anchor the alignment mechanism also supports x/y OFFSETS. A top/right aligned group with a -40/20 offset will appear with its anchor (40 * UI Scalar) pixels leftward from the right of your screen and (20 * UI Scalar) pixels downward from the top of your screen.
3. **UI Scalar:** This library supports UI scalars. Both the previously mentioned OFFSETS and your defined element sizes will be scaled with your current UI scalar. This means that for users with large 4k monitors and a large x2.5 UI scalar, this lib's groups will grow to be 2.5x larger than normal, so that they do not render at a miniscule size compared to your UI scalar. This also allows offsets to keep pace with the vanilla UI's offsets, since the vanilla UI's offsets get scaled too BTW. This is why this demo's vanilla_ui mockup's top-right anchor stays synced with the actual vanilla UI's top-right corner, as both are scaling with your UI scalar!
4. **Visuals:** This library supports many default visuals! This means that you can easily add visuals to your elements. [See the UI Demo addon's code for sample syntax.)](https://github.com/Roland-J/UI-Mockup-Groups-Lib-Demos-)  The provided visuals are:
    - [_left/middle/right_]\_click_[_travel/toggle/bulge/tint/color_]
    - scroll_zoom
    - hover_[_travel/bulge/tint/arrow/color_]
4. **Zoom:** As you may have noticed in the visuals, this library supports zooming in/out of a group via the mouse scroll wheel. The zoom feature provides three "focus" settings:
    - **No focus:** The default focus, given when no specific focus is declared. In this mode, the given group will grow outward from its anchor. A top/left aligned group will grow downward and rightward, a center/center aligned group will grow in all directions, whilst a bottom/right aligned group will grow upward/leftward.
    - **Center focus:** Regardless of the group's alignment, it will grow outward from its center. I am expecting this to be the most popular zoom focus.
    - **Cursor focus:** Regardless of the group's alignment, it will grow outward from the cursor. This would be useful for map UIs, for certain.
5. **Events:** Along with visuals, this library supports adding events to any element. This allows you to run your own function when an element is clicked, released, hovered, or scrolled. With events, images and texts can easily become interactable! [See the UI Demo addon's code for sample syntax.)](https://github.com/Roland-J/UI-Mockup-Groups-Lib-Demos-) 
6. **Drag Sync:** All the elements within a group are dragged together when any one of its elements is dragged! This allows you to create clusters of elements easily allow them to be both clickable and draggable, without having to fuss with any complex drag logic!
7. **Drag Bounds:** This feature allows you to define optional bounds which groups cannot be dragged outside of! This will hopefully provide an intuitive and user-friendly way of helping keep the groups on screen, assuming that users wouldn't want to drag a group offscreen.
8. **Group Sync:** This feature allows you to sync multiple groups together. When synced, all groups will A) zoom in/out together, B) drag together, and C) calculate their drag bounds together. This is useful if you have multiple groups where one main element's buttons show/hide the other groups, similar to this demo's vanilla_ui demo UI.
9. **Embedded Elements:** This feature allows you to embed any element into any element belonging to said group. When the main object runs a visual, said visual propagates to all of its embedded elements. This means that you can embed a text into an image serving as a button background and have them both perform a **left_click_travel** visual effect in unison, without requiring nearly any additional code on your part! This is also mocked up in my [UI Mockup (Groups Lib Demos)](https://github.com/Roland-J/UI-Mockup-Groups-Lib-Demos-).
10. **Config/Saving:** This library automatically saves group positions and zoom levels. Any addon utilizing this library will therefore inherently support persistent user preferences regarding group position and zoom! Hurray!
11. **Auto-Hide:** This library also supports auto-hide. This means that while zoning - both between zones and during login/logout - any groups that have auto-hide enabled will disappear when zoning out and reappear when zoning in.
