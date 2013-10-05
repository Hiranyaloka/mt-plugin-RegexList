# REGEXLIST 0.12 FOR MOVABLE TYPE 4, 5, AND MELODY #

Sometimes you may think that a regular expression is the best way to solve your problem. And you are probably wrong. But hey, I'm not here to judge. In fact, I've just cooked up a big chunk of Regex Crack for you, which I've named instead  `RegexList` so you won't scare off any clients.

RegexList is a simple but powerful tag modifier.  With it you can match substrings within your text (with a regex match), then process those substrings further with a second regex replacement, and finally _save those modified substrings into a Movable Type array for template consumption_.

Power comes at a price.The RegexList modifier has up to four arguments! The first two arguments are **EXACTLY** the same in form as the built-in modifier [regex_replace](http://www.movabletype.org/documentation/appendices/modifiers/regex-replace.html) .

## REGEXLIST ARGUMENTS ##
1. The first regex targets the matched substrings (exactly like argument one of `regex_replace`).
2. The second argument is the replacement regex expression (exactly like argument two of `regex_replace`).
3. The third regex matches the substrings only, no capturing parenthesis necessary. It only "feeds" the substrings to the regex_replace function.
4. The fourth argument is optional, being a digit from 1 to 9. I'll [explain this later](#arg4).

The plugin processes the arguments in order of 3 -> 1 -> 2, but I decided to build on the order of the existing `regex_replace` modifier, for familiarity sake, and also because I plan to make `regex_replace` function the default when the third argument is left off.

## WHO THIS  PLUGIN IS FOR ##
You will either need to know a good bit about regular expressions, or know someone who does, in order to take full advantage of this plugin. We'll first examine a simple use case, breaking down the logic for clarity.

## A VERY SIMPLE EXAMPLE: SPLIT A STRING INTO A LIST ##

Let us start simply, explaining each step in detail. We'll start with a string:

    <$mt:Var name="thestring" value="FOO,bar,bLA,Baz"$>
    
Although that value looks like a list, to Movable Type it is a simple string variable. We have assigned a string to a Movable Type variable, just to have something to work with.

Now we will use the `regex_list` modifier to parse the string, capturing the individual words. In order to do this, we must use a regular expression to match only the words, not the comma. The third argument is always the regular expression that matches the substrings, so focus on that for now:

    <$mt:Var name="thestring" regex_list="","","/([^,]+)/" setvar="thelist"$>

The regular expression breaks down like this (this is just standard perl regex syntax):

    /          # start the regular expression
     [^,]      # match any character that is not a comma
         +     #   one or more times
           /   # end the regular expression

We are searching through the string from left to right, matching chunks of string as we go. Notice that the regular expression placed in the third argument is always global, so you don't have to use the global modifier `/my_regex/g`. Also note that we are capturing the entire matched substring by default (more on that later).

OK, so the third argument should have matched four substrings from our original comma-separated value. Those four values are each separately passed to the `regex_replace` function, which is handled by arguments one and two. But for simplicity, let us say that we don't care to further process the substrings. Let's pass them right into the "thelist" array variable. Here's one way to do that, starting with the first argument:

    <$mt:Var name="thestring" regex_list="/(.+)/","","" setvar="thelist"$>
    
Let's break down the first argument (again, this is just standard perl regex syntax):

    /         # start the expression
     (        # start the capture
      .       # match anything
       +      #   one or more times
        )     # end the capture
         /    # end the expression

So we are not really filtering, except that the word must be at least one character. That is the "regex" part of the "regex_replace" function. Note that the capturing parenthesis are critical. Without them, we may have matched something, but we have captured nothing. Using the parenthesis we can match all or parts of the matched string.

The second argument is the "replace" function:

    <$mt:Var name="thestring" regex_list="","$1","" setvar="thelist"$>

The variable `$1` simply refers to the everything captured in the (first) parenthesis of the first argument. The combined result is that we are merely passing on the substrings matched by the third argument regex. The end result of the sequence, is a simple "split on comma" function. Now put it together:

    <$mt:var name="thestring" value="FOO,bar,bLA,Baz"$>
    <$mt:Var name="thestring" regex_list="/(.+)/","$1","/([^,]+)/" setvar="thelist"$>

We can now use our new array variable:

    <ul>
    <mt:Loop name="thelist">
    <li><mt:Var name="__value__"></li>
    </mt:Loop>
    </ul>

Those seven lines will output the following:

- FOO
- bar
- bLA
- Baz

## NEXT STEP: PROCESS OUR MATCHED WORDS ##

So we can match substrings (with the third argument) and pass them basically untouched into a MT array variable. Pretty nice, but let's leverage the regex_replace function provided by arguments one and two. Let's clean up the capitalization with case-folding prefixes and case-folding spans. A quick review of case-folding in perl regular expressions:

`\u` and `\l` prefixes force the subsequent character to be uppercase or lowercase, respectively.

`\U` and `\L` spans forces the subsequent character(s) to be upper- or lowercased, respectively, until they reach a new case-fold, or until they are terminated by a `\E`.

So if we replace the `regex_list` line like this (keeping the other six lines the same):

    <$mt:Var name="thestring" regex_list="/(.)(.+)/","\u$1\L$2\E","/([^,]+)/" setvar="thelist"$>

Briefly, we have split the first regex match argument into two captures. The first captures only the first character, and the second captures the rest. We then uppercase `$1` and lowercase `$2` in the second argument. The end result is changed:

- Foo
- Bar
- Bla
- Baz

Pretty cool, yeh? There is no end to the manipulations made possible by the regex_list modifier, due to the inherent power of perl regular expressions. Next we will do somethin a bit more useful.

## BUILD AN AUTOMATIC TABLE OF CONTENTS FROM PAGE BODY TEXT ##

We will now create an automated widget for linking to page bookmarks. We would start by manually placing bookmarks above each of our main page sections (e.g. above the h2 headings). Here's the general format for these "bookmarks":

    <a name="sliders">White Castle Hamburgers</a>

The challenge is to match each of these bookmarks in a page, and create a list of links to each of the bookmarks.

The builtin `regex_replace` modifier will allow us to _replace_ all our bookmarks with links. That's not very useful in itself, but follow along and you'll see why we want to do that. Here's the "regex" half of the "regex_replace" modifier:

    /<a name=(['"])(.+?)\1>(.*?)</a>/i

The first parenthesis captures the first quotes (single or double), and the backreference `\1` repeats that. The second and third parenthesis captures the required link name and the optional anchor text. We'll be using `$2` and `$3` backreferences to place those bits in our replacement argument. The `i` modifier gives us case insensitivity.

(Please note that if you expect extra spaces in your page bookmarks, you'll want to toss in some `\s*` space metacharacters. Also, note that forward slashes within the regexesdo not need escaping as they would in perl code.)

The bookmark link will look like this:

    <a href="#sliders">White Castle Hamburgers</a>

The replacement argument is simple. We just fill in the variable bits with the backreferences. Since this isn't a regex, we don't need to escape special characters.

    <a href="#$2">$3</a>

(Don't forget, backreferences within the regex start with a backslash `\1`, whereas backreferences in the replacement argument use the dollar sign `$1`.)

The third argument is the key to RegexList's power. Instead of operating on the text in place, we provide the modifier with a second regex to match and extract the substrings first. Again, this is the third argument, but logically it is the first step in the algorithm. This regex will likely look very much like the first regex. The key difference is that we don't bother to capture the variable bits:

    /(<a name=(['"]).+?\2>.*?</a>)/i

That regex is used soley to gather the substrings, and pass them to the "regex_replace" function created from the first two arguments. As stated earlier, the second regex (third argument) is always global. You can put the `g` modifier there or not, but the expression is processed globally.

###  PUTTING  IT TOGETHER ###

You now have your three arguments, this is what that will look like inside the PageBody tag (first without the arguments):

    <mt:PageBody regex_list="","","" setvar="pagelinks">

We are going to feed the tag modifier output into a Movable Type variable `pagelinks`. The variable will be an array. More on that later, let's fill in the arguments:

    <mt:PageBody regex_list="/<a name=(['"])(.+?)\1>(.*?)</a>/i","<a href="#$2">$3</a>","/(<a name=(['"]).+?\2>.*?</a>)/i" setvar="pagelinks">

That is an ugly beast, no doubt. But it packs a wallop. BTW, that is not your actual `PageBody` tag, you call a separate one for the sole purpose of generating the list. Because you use `setvar` to set the array variable, the tag produces no output. Now let's see how you make a nice list of links from that.

   

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

<a name="arg4"></a>
## THE OPTIONAL FOURTH ARGUMENT ##
By default, the substring matched by the third argument is stored in its entirety into the array to be "regex-replaced". In technical terms we have captured using the `$&` capture variable. That should be the most common case. But suppose that you don't want to match the entire string that was required in the regex. You have total control merely by specifying the capture portion as a digit from 1 to 9. As an example, say that you only wanted to match image links that were associated with a certain parent structure. This would be your third argument:

    /<span class="hot">(<img src=.*?/>)</span>/
    
In the above case, we would want to set the fourth argument to "1", meaning that we only wish to capture the image tag (which is contained by the first capturing parentheses).

I may (in future releases) extend the optional fourth argument to include multi-digit integers. So for example `42` would indicate to concantenate the fourth and second capture before passing to the regex_replace function. That suggests yet a **fifth** argument, which would be the "glue" between the captured chunks. Yes, five arguments, but that's it, I promise absolutely no more than five, ever.

## LOGGING ##
TO aid in development of your regular expressions, the `regex_list` modifier logs each time that a regular expression matches. I will create a configuration setting to turn logging on and off.

## ROADMAP ##
- Configuration setting to turn off logging of regex matches.
- Make the modifier work just like `regex_replace` when only two arguments are used.
- Extend the fourth argument to multiple digits (captures), and add a fifth "glue" argument.
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
