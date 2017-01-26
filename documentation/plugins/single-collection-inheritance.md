---
layout: documentation
title: Single Collection Inheritance
---

Single Collection Inheritance ("SCI") allows you to store multiple types of similar documents into a single collection. The most common case is when you have a hierarchy of objects that inherit behavior and attributes.

{% highlight ruby %}
class Field
  include MongoMapper::Document
  key :name, :required => true
end

class FileUpload < Field
  plugin Joint
  attachment :file
  validates_length_of :file_size, :minimum => 0, :maximum => 10.megabytes
end

class TextField < Field
end

class RadioButton < Field
  many :options
end
{% endhighlight %}

When you inherit from a model, MongoMapper adds at `_type` attribute to your model, which is set when your model is created.

Extra Resources
---------------

[Why I Think Mongo is to Databases What Rails was to Frameworks](http://railstips.org/blog/archives/2009/12/18/why-i-think-mongo-is-to-databases-what-rails-was-to-frameworks/) see **2. Single Collection Inheritance Gone Wild**

[Single Table Inheritance in Rails](http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html) by Alex Reisner. A good resouce on the why, what, and when of STI.