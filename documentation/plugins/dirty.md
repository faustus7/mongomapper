---
layout: documentation
title: Dirty
---

Provides a way to track changes in your documents. Each attribute in your document gets the suffix methods `_changed?`, `_change`, `_will_change!`, and `_was`. Saving a document clears all changes.

Examples
--------

{% highlight ruby %}class User
  include MongoMapper::Document

  key :name, String
  key :age, Integer
end

user = User.create(:name => 'John', :age => 29)

puts user.changed?        # false
puts user.changes.inspect # {}

user.name = 'Steve'
puts user.changed?            # true
puts user.changes.inspect     # {"name"=>["John", "Steve"]}
puts user.name_changed?       # true
puts user.age_changed?        # false
puts user.name_was            # 'John'
puts user.name_change.inspect # ["John", "Steve"]
user.save                     # clears changes
puts user.changed?            # false{% endhighlight %}