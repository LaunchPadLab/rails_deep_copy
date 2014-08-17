Rails Deep Copy
======================

The purpose of Rails Deep Copy is to provide an automated means of duplicating an ActiveRecord object with deeply nested children. The gem will recursively create these nested objects, ensuring that all foreign keys are appropriately synced to the newly generated copies.


**Supported relationships:**

* has_many
* has_many :through
* has_one
* has_one :through


Usage
----------------------

```ruby
@project = Project.find(123)
@project_copy = RailsDeepCopy::Duplicate.create(@project)
```

**Associated objects are automatically duplicated too!**
```ruby
@project.discussions.count
#=> 3
@project.discussions.first.posts.count
#=> 6

@project_copy.discussions.count
#=> 3
@project.discussions.first.posts.count
#=> 6
```


Overrides
----------------------

