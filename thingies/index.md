---
layout: projects
title: Projects
---

Here you can find various things I have worked on, either created by me or which I contributed to. Check out my [GitHub](https://github.com/kalimatas) profile for code.

<div style="margin-bottom: 20px;">&nbsp;</div>

{% for project in site.projects %}
<div class="entry">
	<h3><a href="{{ project.url }}">{{ project.title }}</a></h3>
	<div>
		{{ project.content | markdownify }}
	</div>
</div>
{% endfor %}

<!-- transform each to a separate project -->

## Contributions

<a href="https://github.com/google/go-github" target="_blank">go-github</a> - Go client library for GitHub API (milestone API).

