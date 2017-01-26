---
layout: documentation
title: Serialization
---

MongoMapper provides ActiveModel-compatible serialization for building an XML or JSON representation of your model.

{% highlight ruby %}
class User
  include MongoMapper::Document

  key :name,        String
  key :email,       String
  key :friend_ids,  Array

  many :interests
  many :friends, :class_name => 'User', :in => :friend_ids

  def newest_friend
    User.find(friend_ids.last)
  end
end

class Interest
  include MongoMapper::EmbeddedDocument

  key :title, String
end

user = User.create(:name => "Foo", :email => "foo@bar.com",
    :interests => [Interest.new(:title => "Movies")])
{% endhighlight %}

Call `to_json` or `to_xml` on your model to return a serialized string, or `serializable_hash` to simply return a plain Ruby hash.

{% highlight javascript %}
{
  "id":       "4da66b02217dd45643000323",
  "name":     "Foo",
  "email":    "foo@bar.com",
  "interests": [
    {"id": "4dac5bd2c198a708f5000001", "title": "Movies"}
  ]
}
{% endhighlight %}

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <id>4da66b02217dd45643000323</id>
  <name>Foo</name>
  <email>foo@bar.com</email>
  <interests type="array">
    <interest>
      <title>Movies</title>
      <id>4dac5ce0c198a70912000003</id>
    </interest>
</user>
{% endhighlight %}

Note that [embedded documents](/documentation/embedded-document.html) are included in the serialized output without any intervention.

Customizing Serialized Output
-----------------------------

The `to_json` and `to_xml` methods take a few options, namely **:only**, **:except** and **:include**. The first two are straightforward filters for the generation of the serialized output.

{% highlight ruby %}
user.to_json(:only => :name)

user.to_json(:except => :email)
{% endhighlight %}

**:include** lets you include an association or the result of a method in the serialized output.

{% highlight ruby %}
user.to_json(:include => [:friends])
{% endhighlight %}

**:methods** lets you include the result of a method

{% highlight ruby %}
user.to_json(:methods => [:newest_friend])
{% endhighlight %}

Internally, the `serializable_hash` method is used on your model to generate the serialized string. Override it provide your own implementation or to set defaults.

{% highlight ruby %}
  def serializable_hash(options = {})
    super({:except => :password}.merge(options))
  end
{% endhighlight %}