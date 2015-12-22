# Rustynail

This project rocks and uses MIT-LICENSE.

## Create cofig file.

 $ bin/rails g rustynail:config

## Mix-In
Rustynail must be included by class that implementing facet-search.

```ruby 
class Klass < ActiveRecord::Base
  include Rustynail
```
  


## Render Facet Search Options
on view file.
```ruby
<%= render_facet_options( @result ) %>
```
@render is rustynail result object. 

### for initial page ( before search. )
```ruby
@result = Klass.facet_search_initial_result
```
### for search page ( after search. )
```ruby
@result = klass.facet_search( filter )
```

