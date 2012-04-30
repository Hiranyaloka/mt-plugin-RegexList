# REGEXLIST 0.11 FOR MOVABLE TYPE 4, 5, AND MELODY #

Sometimes you may think that a regular expression is the best way to solve your problem. And you are probably wrong. But hey, I'm not here to judge. In fact, I've just cooked up a big chunk of Regex Crack for you, which I've named instead  `RegexList` so you won't scare off any clients.

RegexList is a simple but powerful tag modifier.  With it you can match substrings within your text (with a regex match), then process those substrings further with a second regex replacement, and finally _save those modified substrings into a Movable Type array for template consumption_.

Powerful comes at a price.The RegexList modifier has four arguments! The first two arguments are **EXACTLY** the same in form as the built-in modifier [regex_replace](http://www.movabletype.org/documentation/appendices/modifiers/regex-replace.html):

## REGEXLIST ARGUMENTS ##
1. The first regex targets the matched substrings (exactly like argument one of `regex_replace`).
2. The second argument is the replacement regex expression (exactly like argument two of `regex_replace`).
3. The third regex matches the substrings only, no capturing parenthesis necessary. It only provides the substrings.
4. The fourth argument is optional, being a digit from 1 to 9. I'll explain this later.

The plugin processes the arguments in order of 3 -> 1 -> 2, but I decided to build on the order of the existing `regex_replace` modifier, for familiarity sake, and also because I plan to make `regex_replace` function the default when the third argument is left off.

## WHO THIS  PLUGIN IS FOR ##
You will either need to know a good bit about regular expressions, or know someone who does, in order to take full advantage of this plugin.

## JUST SHOW ME AN EXAMPLE ##

Let's start with a simple example. I have a bunch of page anchors in the page body, and I'd like create an automated widget for linking to them from the sidebar. Here's the general format for the "bookmarks":

    <a name="sliders">White Castle Hamburgers</a>

The `regex_replace` modifier will allow us to _replace_ all our bookmarks with links. That's not very useful in itself, but follow along and you'll see why we want to do that. Here's the "regex" half of the "regex_replace" modifier:

    /<a name=(['"])(.+?)\1>(.*?)</a>/i

The first parenthesis captures the first quotes (single or double), and the backreference `\1` repeats that. The second and third parenthesis captures the required link name and the optional anchor text. We'll be using `\2` and `\3` backreferences to place those bits in our replacement argument. The `g` modifier means we are searching globally (we want all such links) and the `i` modifier gives us case insensitivity.

Her's what the bookmark link will look like:

    <a href="#sliders">White Castle Hamburgers</a>

The replacement argument is simple. We just fill in the variable bits with the backreferences. Since this isn't a regex, we don't need to escape 

    <a href="#$2">$3</a>

(Don't forget, backreferences within the regex start with a backslash `\1`, whereas backreferences in the replacement argument use the dollar sign `$1`.)

The third argument is the key to RegexList's power. Instead of operationg on the text in place, we provide the modifier with a second regex to match and extract the substrings first. Again, this is the third argument, but logically it is the first step in the algorithm. This regex will likely look very much like the first regex. The key difference is that we don't bother to capture the variable bits:

    /(<a name=(['"]).+?\2>.*?</a>)/i

That regex is used soley to gather the substrings, and pass them to the "regex_replace" function created fromn the first two arguments. The second regex (third argument) is always global. You can put the `g` modifier there or not, but the expression is processed globally. Because that is the point of the modifier.

###  PUTTING  IT TOGETHER ###

You now have your three arguments, this is what that will look like inside the PageBody tag (first without the arguments):

    <mt:PageBody regex_list="","","" setvar="pagelinks">

We are going to feed the tag modifier output into a Movable Type variable `pagelinks`. The variable will be an array. More on that later, let's fill in the arguments:

    <mt:PageBody regex_list="/<a name=(['"])(.+?)\1>(.*?)</a>/i","<a href="#$2">$3</a>","<mt:PageBody regex_list="","","" setvar="pagelinks">" setvar="pagelinks">

That is an ugly beast, no doubt. But it packs a wallop. BTW, that is not your actual `PageBody` tag, you call a separate one for the sole purpose of generating the list. Now let's see how you make a nice list of links from that.

   

### USING THE LIST VARIABLE ###

We can place the list code anywhere on the page after the variable was created: 

    <ul>
    <mt:Loop name="pagelinks">
      <li>
        <mt:Var name="__value__">
      </li>
    </mt:Loop>
    </ul>

And you are done!!!

## THE FOURTH ARGUMENT ##
By default, the substring matched by the third argument is stored in its entirety into the array to be "regex-replaced". In technical terms we have captured using the `$&` capture variable. That should be the most common case. But suppose that you don't want to match the entire string that was required in the regex. You have total control merely by specifying the capture portion as a digit from 1 to 9. As an example, say that you only wanted to match image links that were associated with a certain parent structure. This would be your third argument:

    /<span class="hot">(<img src=.*?\/>)</span>/
    
In the above case, we would want to set the fourth argument to "1", meaning that we only wish to capture the image tag (which is contained by the first capturing parentheses).

## LOGGING ##
T0 aid in development of your regular expressions, the `regex_list` modifier logs each time that a regular expression matches. I will create a configuration setting to turn logging on and off.

## ROADMAP ##
- Configuration setting to turn off logging of regex matches.
- Make the modifier work just like `regex_replace` when only two arguments are used.
- Provide more example regexes.
- Improve error handling.
- Localization

## CHANGELOG ##
- version 0.1  Initial Release

##  RELATED PLUGINS ##
Inspiration and code lifted from Movable Type's own `regex_replace` tag modifier.

## SUPPORT ##
Please send questions, comments, or criticisms to rick@hiranyaloka.com.

## REGEXLIST COPYRIGHT AND LICENSE ##

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

This software is offered "as is" with no warranty.

RegexList is Copyright 2012, Rick Bychowski, rick@hiranyaloka.com.
All rights reserved.
