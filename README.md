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


Overrides And Gotchas
----------------------

The gem figures out which children objects need to be duplicated based on the association declarations on the model (has_many, has_one). For example, if a project "has_many :discussions" and and a discussion "has_many :posts", the gem would do the following:

* Step #1. Create a copy of the project
* Step #2. Iterate through each discussion and:

1. Duplicate the discussion
2. Change its project_id to correspond with the newly created project copy
3. Iterate through each of the discussion's posts and repeat 1 and 2


**Determine which associations are duplicable**
```ruby
class Project
  has_many :discussions
  has_many :posts
  DUPLICABLE_ASSOCIATIONS [:discussions]

end

class Discussion
  has_many :posts

end

RailsDeepCopy::Duplicate.create(Project.last)









```ruby
class Discussion
  # Change which associations are duplicable (empty array for none)
  DUPLICABLE_ASSOCIATIONS = [:posts, :members]

  # Set default attribute values when object is duplicated
  DUPLICABLE_DEFAULTS = {title: "Great discussion title", description: "This is a default description of the copied discussion"}
end
```



