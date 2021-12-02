---
title: "Consistent modal dialogs, the easy way"
date: "2011-07-20"
---

So we all know the default alert dialog box visually sucks. Any of the hundreds of jQuery modal plugins work wonderfully for replacing it with something a bit snazzier (although putting the information on the page for a user is even better, but that's for another post). The biggest problem with most of those dialogs are either the setup cost, or the memory cost:

- **Setup cost**: having to set heights, widths, button names, text & title fields, yada, yada, yada. A lot of that can be skinned through CSS, and a lot of plugins reduce that noise to virtually nil, but many leave a lot on your pages. It's ugly to look at in your code, and ugly to configure. Not to mention all those config settings spreads through your code base like the freakin' ground ivy is spreading through my lawn as I type this. Want to change the widths for a new redesign, or localize the button names? Good luck!
- **Memory cost**: relates to the [Pit of Success](http://darrell.mozingo.net/2011/06/26/the-pit-of-success/). Do you really want the burden of always remembering to use that modal dialog instead of alert? What about the new guy, is he going to know or remember? Sure, forgetting isn't _that_ big of a deal, but given enough slip ups and your nice consistent UI goes to hell. Tests checking for calls to alert are also possible via straight searching through files or through UI tests some how, but I can see a future of false positives ahead of that idea.

How about a better way? With some very slight Javascript-foo, you can override the default alert and confirm dialogs so not only is there nothing to copy & paste between pages, but you don't even have to remember to use your nifty modal boxes - it'll just happen. We'll use the [jQuery UI Dialog](http://jqueryui.com/demos/dialog/) plugin inside a stock ASP.NET MVC app, though this is easily transferable to any other platform or with any other modal plugin.

First we'll override the default `alert` method on the `window` object, calling the dialog function from jQuery UI and setting some default parameters:

```javascript
window.alert = function (message) {
    $("#dialog")
    .html("")
    .html('' + message)
    .dialog({
        autoOpen: true,
        resizable: false,
        height: 200,
        width: 350,
        title: "Alert!",
        modal: true,
        buttons: {
            "OK": function () {
                $(this).dialog("close");
                return;
            }
        }
    });
};

alert("Error!!!");
```

The HTML is cleared out and a default alert icon (from jQueryUI) is added via the class attribute `ui-icon-alert`. This allows us to create a standard `<div id="dialog"></div>` in our master page with nothing inside it, and reuse it for alert/confirm/prompt boxes. Then a standard alert call, like the one at the bottom, gives us:

![Alert modal dialog](/assets/2011/alert_modal.png "Alert modal dialog") vs ![Default alert](/assets/2011/alert_default.png "Default alert")

Similarly, we can override the default confirmation box. Here's a version that'll take the title, a message to show, and a callback function to execute if the user clicks "OK":

```javascript
window.confirm = function(title, confirmMessage, successCallback) {
    $("#dialog")
        .html("")
        .html('' + confirmMessage)
        .dialog({
                autoOpen: true,
                resizable: false,
                height: 200,
                width: 350,
                title: title,
                modal: true,
                buttons: {
                    "Yes": function() {
                        $(this).dialog("close");
                        successCallback();
                        return;
                    },
                    "No": function() {
                        $(this).dialog("close");
                        return;
                    }
                }
            });
};
```

confirm("Are you sure?", "Are you sure you want to create a confirm?", function() { alert("Sweet, all done!"); });

Again, compare the results (the first question mark is an icon from jQuery UI, which can also be changed with the class written out in the confirm method above):

![Modal Confirm](/assets/2011/confirm_modal.png "Modal Confirm") vs ![Default Confirm](/assets/2011/confirm_default.png "Default Confirm")

Pretty neat, if you ask me. This whole thing is very [DRY](http://en.wikipedia.org/wiki/Don't_repeat_yourself), as everything you need is referenced in your master page (the dialog div, the javascript & css files, etc) and your individual pages don't need to include anything - just call away. You also don't have to remember to call special methods (or at least terribly special ones in `confirm`'s case). It just works.

It's not too hard to imagine extending this system to override the default `prompt` box either. Just pass in a callback that'll set whatever string you need, similar to how `confirm` works above. Closures work wonders.

You can grab the code used in this post [right here](https://github.com/DarrellMozingo/Blog/tree/master/ConsistentModalDialogs).
