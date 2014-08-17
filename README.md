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

How It Works
---------------------

The gem figures out which children objects need to be duplicated based on the associations on the model (has_many, has_one). For example, if a project "has_many :discussions" the gem would do the following:

1. Create a copy of the project
2. For each of the project's discussions, duplicate the discussion, change project_id to the new project's ID, and save the discussion

Step 2 is actually done on a recursive basis, meaning the gem can handle deeply nested relationships. Consider the following: a project "has_many :discussions", a discussion "has_many :posts", and a post "has_many :comments". The gem will do the following:

Create a copy of the project. For each of the project's discussions, duplicate the discussion, change project_id to the new project's ID. For each of the discussion's posts, duplicate the post, change discussion_id, change project_id (if exists on model). For each of the post's comments, rinse and repeat the same steps, assigning project_id, discussion_id, and post_id when the attributes exist on the model.


Overrides And Gotchas
----------------------

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



