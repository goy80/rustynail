# Rustynail

A Full-Text-Search and Facet-Search form generator for Rails application using Mroonga. 

# Premise
 The model include Rustynail resnponds a table that use Mroonga as strage engine.  
 A sample table constructure is bellow.
 
```sql
CREATE TABLE `a_table` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `column1` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `column2` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `column3` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `column4` int(11) NOT NULL,
  `column5` int(11) NOT NULL,
  `column6` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `idx01` (`column1`,`column2`,`column3`)
) ENGINE=Mroonga DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
```

## Create cofig file.

 $ bin/rails g rustynail:config

## Mix-In and Setting
Rustynail must be included by class that implementing facet-search.

```ruby 
class Klass < ActiveRecord::Base
  include Rustynail
  
  # columns for full-text-search.
  full_text_search_columns [ :column1, :column2, :column3 ]

  # columns for facet-search.
  facet_columns [ :column4, :column5 ]

  # columns for sort.
  # when element of array is symbol of column name,
  # that column is sortable both asc and desc.
  # when element specify as :column_name => [ ( :asc, :desc ) ],
  # that means the column sortable asc or desc.
  sortable_columns [ :column4, :column5,  column6: [ :asc ]  ]
  
  # default sort rule.
  default_sort [ "column6 asc", "column4 desc" ]
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
@result = Klass.facet_search( filter )
```
"filter" is Hash of search condition. 

