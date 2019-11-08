component extends="quick.models.BaseEntity" {

    property name="CBORMCriteriaBuilderCompat" inject="provider:CBORMCriteriaBuilderCompat@quick";

    function list(
        struct criteria = {},
        string sortOrder,
        numeric offset,
        numeric max,
        numeric timeout,
        boolean ignoreCase,
        boolean asQuery = true
    ) {
        structEach( arguments.criteria, function( key, value ) {
            variables.retrieveQuery().where(
                variables.retrieveColumnForAlias( arguments.key ),
                arguments.value
            );
        } );
        if ( ! isNull( arguments.sortOrder ) ) {
            variables.retrieveQuery().orderBy( arguments.sortOrder );
        }
        if ( ! isNull( arguments.offset ) && arguments.offset > 0 ) {
            variables.retrieveQuery().offset( arguments.offset );
        }
        if ( ! isNull( arguments.max ) && arguments.max > 0 ) {
            variables.retrieveQuery().limit( arguments.max );
        }
        if ( arguments.asQuery ) {
            return variables.retrieveQuery().setReturnFormat( "query" ).get();
        } else {
            return super.get();
        }
    }

    function countWhere() {
        for ( var key in arguments ) {
            variables.retrieveQuery().where(
                variables.retrieveColumnForAlias( key ),
                arguments[ key ]
            );
        }
        return variables.retrieveQuery().count();
    }

    function deleteById( id ) {
        arguments.id = isArray( arguments.id ) ? arguments.id : [ arguments.id ];
        variables.retrieveQuery().whereIn( get_key(), arguments.id ).delete();
        return this;
    }

    function deleteWhere() {
        for ( var key in arguments ) {
            variables.retrieveQuery().where(
                variables.retrieveColumnForAlias( key ),
                arguments[ key ]
            );
        }
        return super.deleteAll();
    }

    function exists( id ) {
        if ( ! isNull( arguments.id ) ) {
            variables.retrieveQuery().where( get_key(), arguments.id );
        }
        return variables.retrieveQuery().exists();
    }

    function findAllWhere( criteria = {}, sortOrder ) {
        structEach( arguments.criteria, function( key, value ) {
            variables.retrieveQuery().where(
                variables.retrieveColumnForAlias( arguments.key ),
                arguments.value
            );
        } );
        if ( ! isNull( arguments.sortOrder ) ) {
            var sorts = listToArray( arguments.sortOrder, "," ).map( function( sort ) {
                return replace( arguments.sort, " ", "|", "ALL" );
            } );
            variables.retrieveQuery().orderBy( sorts );
        }
        return super.get();
    }

    function findWhere( criteria = {} ) {
        structEach( arguments.criteria, function( key, value ) {
            variables.retrieveQuery().where(
                variables.retrieveColumnForAlias( arguments.key ),
                arguments.value
            );
        } );
        return super.first();
    }

    function get( id = 0, returnNew = true ) {
        if ( ( isNull( arguments.id ) || arguments.id == 0 ) && arguments.returnNew ) {
            return super.newEntity();
        }
        return invoke( this, "find", { id = arguments.id } );
    }

    function getAll( id, sortOrder ) {
        if ( isNull( arguments.id ) ) {
            if ( ! isNull( arguments.sortOrder ) ) {
                var sorts = listToArray( arguments.sortOrder, "," ).map( function( sort ) {
                    return replace( arguments.sort, " ", "|", "ALL" );
                } );
                variables.retrieveQuery().orderBy( sorts );
            }
            return super.get();
        }
        var ids = isArray( arguments.id ) ? arguments.id : listToArray( arguments.id, "," );
        variables.retrieveQuery().whereIn( get_key(), ids );
        return super.get();
    }

    function new( properties = {} ) {
        return super.newEntity().fill( arguments.properties );
    }

    function populate( properties = {} ) {
        super.fill( arguments.properties );
        return this;
    }

    function save( entity ) {
        if ( isNull( arguments.entity ) ) {
            return super.save();
        }
        return arguments.entity.save();
    }

    function saveAll( entities = [] ) {
        arguments.entities.each( function( entity ) {
            arguments.entity.save();
        } );
        return this;
    }

    function newCriteria() {
        return variables.CBORMCriteriaBuilderCompat.get()
            .setEntity( this );
    }

}
