---
layout: default
companies:
  - name: New York Times
    link: http://open.blogs.nytimes.com/2010/05/25/building-a-better-submission-form/
    logo: nyt.png
  - name: Heroku
    link: http://heroku.com
    logo: heroku.png
  - name: Harmony
    link: http://harmonyapp.com
    logo: harmony.png
  - name: Posterous
    link: http://posterous.com
    logo: posterous.png
  - name: Yottaa
    link: http://www.yottaa.com/
    logo: yottaa.jpg
  - name: The Movie DB
    link: http://www.themoviedb.org/
    logo: themoviedb.png
  - name: IGN
    link: http://www.ign.com/
    logo: ign.png
  - name: Intuit
    link: http://www.intuit.com/
    logo: intuit.png
---

A Mongo ORM for Ruby
====================

Built from the ground up to be simple and extendable, MongoMapper is a lovely way to model your applications and persist your data in MongoDB. It has all the bells and whistles you need to get the job done and have fun along the way.

Getting Started
---------------

Install the MongoMapper gem:

{% highlight sh %}
$ gem install mongo_mapper
{% endhighlight %}

Define your models:

{% highlight ruby %}
class User
  include MongoMapper::Document

  key :name, String
  key :age,  Integer

  many :hobbies
end


class Hobby
  include MongoMapper::EmbeddedDocument

  key :name,    String
  key :started, Time
end
{% endhighlight %}

Use your models to create and find documents:

{% highlight ruby %}
user = User.new(:name => 'Brandon')
user.hobbies.build(:name => 'Programming',
  :started => 10.years.ago)

user.save!

User.where(:name => 'Brandon').first
{% endhighlight %}

Check out the [Documentation](/documentation/)

Who's Using MongoMapper?
------------------------

<ul class="using">
{% for company in page.companies %}

<li>
<a href="{{ company.link }}">
<img src="/images/using/{{ company.logo }}" alt="{{ company.name }}" />
</a>

</li>
{% endfor %}

</ul>