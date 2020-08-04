[General info](index.html).

## Projects

<% data.projects.each do |project| %>
*   ### <%
      if project.link
    %>[<%= project.title %>](<%= project.link %>){:target="_blank" rel="noreferrer noopener"}<%
      else
    %><%= project.title %><%
      end
    %>

    **<%= project.years %>**

    <%= project.description.split("\n").join("\n    ") %>

    Technologies:
    <% project.technologies.each do |technology| %>
    *   <%= technology %><% end %>
<% end %>{: .projects }
