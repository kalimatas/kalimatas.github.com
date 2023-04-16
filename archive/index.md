---
layout: page
title: Archive
---

<ul class="list_archive">
{% for post in site.posts %}
	{% unless post.next %}
		<h2>{{ post.date | date: '%Y' }}</h2>
	{% else %}
		{% capture year %}{{ post.date | date: '%Y' }}{% endcapture %}
		{% capture nyear %}{{ post.next.date | date: '%Y' }}{% endcapture %}
		{% if year != nyear %}
			<h2>{{ post.date | date: '%Y' }}</h2>
		{% endif %}
	{% endunless %}

	<li>
		{% if post.external_link %}
			<a href="{{ post.external_link }}" target="_blank">{{ post.title }}</a>
			<a href="{{ post.url }}">◉</a>
		{% else %}
			<a href="{{ post.url }}">{{ post.title }}</a>
		{% endif %}
	</li>
{% endfor %}
</ul>
