# ExDocMakeup

The default syntax highlighting used by ExDoc is not very good.

ExDocMakeup is a custom markdown processor that is meant to be used together with ExDoc.
It brings syntax highlighting by [Makeup](https://hexdocs.pm/makeup/Makeup.html)
([demo here](https://tmbb.github.io/makeup_demo/elixir.html)) to your package's documentation.
Makeup is a pure Elixir library to make your code prettier.

Makeup's syntax highlighting is much better than the default syntax highlighting used by ExDoc,
which is based on the [highlight.js](https://highlightjs.org) javascript library.

This package highlights the elixir code in your documentation, while using highlight.js
for languages it can't yet highlight.

**Note:**
Makeup colors your code using pure HTML and CSS, but it uses Javascript for further enhancements.
When you place the mouse cursor over a delimiter (`[`, `]`, `%{` `{`, `}`, etc.)
or a keyword such as `do`, `end`, `fn`, etc., it highlights the matching delimiter or keyword.
Except for this feature, syntax highlighting will work perfectly well without Javascript.

## Installation

This package is [available in Hex](https://hexdocs.pm/ex_doc_makeup).

It can be installed by adding `ex_doc_makeup` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    ...
    # Note the ex_doc version, it won't work with earlier versions
    {:ex_doc, ">= 0.18.1", only: :dev},
    {:ex_doc_makeup, "~> 0.1.0", only: :dev}
  ]
end
```

To configure ExDoc to use ExDocMakeup for better syntax highlighting,
add the following to your `:docs` key:

```elixir
  docs: [
    ...
    markdown_processor: ExDocMakeup,
    ...
  ]
```

When you run `mix docs`, `ex_doc` will use this package for better syntax highlighting.

## CSS Style

The style is what I have decided to call the *Samba Theme*.
It is a slightly customized mixture of two themes, shamelessly stolen from Pygments.

  * the *Tango* theme for the *Day Mode*.
    This theme is based on the color palette from the
    [Tango Icon Theme Guidelines](http://tango.freedesktop.org/Tango_Icon_Theme_Guidelines).

  * the *Paraíso Dark* theme for the *Night Mode*;
    This theme was created by by [Jan T. Sott](https://github.com/idleberg)
    with the [Base16 Builder](https://github.com/chriskempson/base16-builder)
    by [Chris Kempson](https://github.com/chriskempson).
    It was originally inspired by the work of Brazilian artist Rubens LP.

Both themes are owned by the Pygments team and were published under the BSD license.

ALthough the theme is different from the default one used by ExDoc,
it works well with the default color scheme used by ExDoc.

### Naming

The first theme is named after an Argentinian dance,
and the second one is named after a Brazilian artist.
*Samba*, a Brazilian dance, is an appropriate name for the mixture of the two themes.

The fact that the CSS Theme is named after a Portuguese word is not a coincidence.
It's part of my effort to further the agenda of the Great Software Brazilian Conspiracy,
as I've [once promised José Valim](https://elixirforum.com/t/discussion-about-syntax-preferences-split-posts/3436/81).

## Experimental Features

The ability to pass additional keywords has been removed for performance reasons.
It might be added in future versions.
