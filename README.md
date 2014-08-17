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

Beware of your relationships. The gem will use both the parent and children relationships to determine what objects to duplicate in the database.

If you have two models that both "has_many" of the same child model, the gem may create two versions of the same duplicate. For example, let's say I have a project that "has_many :discussions" and "has_many :posts", and a discussion also "has_many :posts". The gem would iterate through each of the project's posts and duplicate them, then iterate through each of the project's discussions' posts, and duplicate them as well. Most likely, I need to change my Project to Post relationship like so: a project "has_many :posts, through: :discussions". However, if this is not correct for your application, you can override which associations are duplicable for a given model like so:

**Determine which associations are duplicable**
```ruby
class Project
  has_many :discussions
  has_many :posts
  DUPLICABLE_ASSOCIATIONS [:discussions]

end
```
