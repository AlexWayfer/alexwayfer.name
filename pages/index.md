Hello. My name is Alexander (Aleksandr) Popov.

I'm <span class="age"><%= Moments.difference(Date.new(2013, 8, 31), birthday).in_years %></span>
years old, but I think it doesn't matter: please, rate person experience and opinions.

I'm from Moscow (Russia), but I also think that it doesn't matter:
I can relocate and make the same things in a lot of places.

## Education

I've not finished higher (Bachelor) education in Russia,
because I don't like such disciplines like philosophy, history,
quantum physics and computer chipsets from the '90s.

But I'm ready for Computer Science in a good university (guess in another country).

## English language

As you might have notice, my level of English not so good, around Intermediate,
but I do my best and I like it more than Russian, probably because of its laconism and simplicity.

And I want to learn it more, but it's easier when living (or communicating) with English speakers.

I use my gadgets (smartphone, PC, etc.) and all services (sites) in English,
I search any information in English,
and I use English for open-source discussions and all commits.

[My streams](http://twitch.tv/AlexWayfer) mostly in Russian because I want to raise
the culture of software development in Russian-speaking community.

## Software development

### General

I love [Ruby Language](https://www.ruby-lang.org/){:target="_blank" rel="noreferrer noopener"}.

I don't like `camelCase` and `functional()` styles.

But I can write a code in any language.
My experience includes C, C++, Qt, Pascal, Delphi, Go, PHP, Java, JavaScript.
Especially JavaScript. But I don't like them so much.

### Specialization

I'm Software Engineer. I were leading a team with up to 10 members.
I can design application architecture. Also usually I communicate with other teams
(like Mobile Development) and departaments (like Marketing).

### Skills levels

[CodersRank profile](https://profile.codersrank.io/user/alexwayfer){:target="_blank" rel="noreferrer noopener"}.

### Open-source projects and activity

I love open-source too much, here is my [GitHub profile](https://github.com/AlexWayfer){:target="_blank" rel="noreferrer noopener"}.

### Projects (experience)

[Complete list on this site](projects.html).

## Tastes

<% data.tastes.each do |taste| %>
*   <%= taste %>
<% end %>

## Contacts

<% data.contacts.each do |contact| %>
*   [<%= contact.title %>](<%= contact.link %>){:target="_blank" rel="noreferrer noopener"}<br>
    <%= contact.description %>
<% end %>
