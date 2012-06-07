Overview
============

So, I really liked the look of [jQuery knob][knob], but I needed a UI control
that was completely read-only and that worked well with [KnockoutJS][ko]. Hence,
this small thing.

Usage
-----

To get started, do this:

    $('.thing').gauge();

If you change values, do this and it'll redraw itself:

    $('.thing').gauge('redraw', newCurrentValue, newMaximumValue);

  [knob]: http://anthonyterrien.com/knob/
  [ko]: http://knockoutjs.com/
