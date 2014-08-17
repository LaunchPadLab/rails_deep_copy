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


Options
----------------------

RailsDeepCopy::Duplicate.create(object, options = {})

**Options and their defaults:**
* changes: {}
* associations: {}
* exclude_associations: {}
* skip_validations: true

```ruby
@project = Project.find(122)
RailsDeepCopy::Duplicate.create(@project, changes: {name: "New Project's Name", description: "A great description"}, skip_validations: false)
```


Overrides And Gotchas
----------------------

**Set Duplicable Associations**

Beware of your relationships. The gem will use both the parent and descendant relationships to determine which objects to duplicate in the database. You can also override which associations are duplicable on your model like so:

```ruby
class Project
  has_many :discussions
  has_many :posts
  DUPLICABLE_ASSOCIATIONS = [:discussions]
  # don't want to duplicate posts here since they are duplicated at the discussion level
  # note that 'has_many :posts, through: :discussions' would solve this problem too
end

class Discussion
  has_many :posts
end

class Post

end

```


**Set Default Values for a Duplicated Object**

```ruby
class Project
  has_many :discussions
  DUPLICABLE_DEFAULTS = {name: "Project Copy", description: "A new awesome project"}
end
```
