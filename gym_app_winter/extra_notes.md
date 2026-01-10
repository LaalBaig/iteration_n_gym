Furnishing the Current UI (Pre-Navigation)
Looking at the provided screenshot, you have a solid, clean foundation. The colors and structure match the design system goals.

However, to truly achieve the "high information density" you are aiming for, the current implementation needs refinement before we add navigation. The current tiles are too sparse.

Here are actionable ways to "furnish" this screen to meet your high-performance goals:

1. Crucial: Elevate Information Density in Tiles
Currently, the tiles show name and lastLog (which appears to be just a date placeholder). For an exercise-centric app, this is insufficient data. A user shouldn't have to tap into an exercise just to see how strong they are at it.

Suggestion: Update the ExerciseTile to display a key performance metric in the subtitle instead of just the date.
Current: lastLog0 (Too vague, low contrast)
Proposed: Show the "Best Set" from the last session or an estimated 1RM (One-Rep Max).
Example Visual Update: Instead of:

Bench Press Last: 10/24/23

Change it to:

Bench Press 100kg x 5 reps (Last Session)

This immediately tells the user their current capability level as they scroll the list.

2. Visual Polish & Contrast
Subtitle Contrast: The gray color used for the lastLog text in the screenshot is too light against the light gray tile background. It struggles with readability. Darken this gray slightly to improve accessible contrast.
Icon Container size: The white rounded square containing the blue dumbbell icon is quite large relative to the text. To improve density, shave 4-8 pixels off the width and height of that container. This will allow more tiles to fit on the screen without feeling cluttered.
3. Search Bar Micro-Interactions
The search bar is clean, but high-performance apps have great micro-interactions.
Clear Button: As soon as the user types one character, a small 'X' icon should appear on the right side of the search bar to clear the text instantly.
Focus State: When the user taps the search bar, give it a very subtle blue border or shadow to indicate it's active.
4. The "Add Exercise" Button (FAB)
The current button is a wide, rounded rectangular button resting above the bottom navigation bar.
Issue: While clear, it occupies significant vertical screen real estate, potentially covering the last item in your list.
Suggestion (High-Performance Tweak): Implement a ScrollController on your ListView. When the user scrolls down (to see more exercises), animate the "Add Exercise" button off-screen or shrink it into a smaller circular FAB. When they scroll up, bring it back. This maximizes the viewing area for your data.
Summary of Next Steps
Before connecting the onTap navigation, I strongly recommend implementing point #1 (elevating information density).

Changing the subtitle from a simple date to actual performance data (e.g., weight x reps) is the single biggest step you can take to realize your vision of an exercise-centric, high-density tracking app.