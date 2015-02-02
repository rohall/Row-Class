# Row-Class
A racket module which allows the creation and modification of object instances from database rows.  These instances can be created, updated, and queried.  This package is still very much a work in progress and may receive significant changes in the future.  Currently only supports Mysql.

## Usage

### Setting up a class as a Row Object
Your class must extend row-object% and use the interface row-object-interface as seen here:
```
(define book%
  (class* row-object% (row-object-interface) 
    (init-field [id 1])
    (init-field [title 1])
    (init-field [author 1])
    (define/public (get-table-name) "books")
    (define/public (get-attributes) (list "id" "title" "author"))
    (super-new)))
```

`row-object-interface` requires that your class defines two methods:

`get-table-name` which returns a string with the name of the table representing this class

AND

`get-attributes` which lists the columns used by this class.  **NOTE: Currently the order of this list must be the same order of the init-field definitions.  Every attribute in this list must also have a corresponding init-field definition.**

### Creating a new instance 
You can create an instance of a row-object like you would any other object:

```
(define new-book (new book% [id 5] [title "Game of Thrones"] [author "GRR Martin"]))
```

The first time you persist an object to the database you must send it the `create!` method with a database connector:

```
(send new-book create! dbc)
```

After that, you can persist single attributes or the entire instances object set with `save-attr!` or `save!`:

```
(set-field! title new-book "A Dance with Dragons")
(send new-book save! dbc)
```

### Querying for existing instances

You can get a list of all object instances of a given class with:

```
(make-from book% dbc)
```

Optionally, you can supply a where clause which will be passed to the SQL server:

```
(make-from book% dbc "id=2")
```
