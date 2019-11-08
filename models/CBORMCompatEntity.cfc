component extends="quick.models.BaseEntity" {

    property name="CBORMCriteriaBuilderCompat"
             inject="provider:CBORMCriteriaBuilderCompat@quick";

    public any function list(
        struct criteria = {},
        string sortOrder,
        numeric offset,
        numeric max,
        numeric timeout,
        boolean ignoreCase,
        boolean asQuery = true
    ) {
        structEach( arguments.criteria, function( key, value ) {
            variables
                .retrieveQuery()
                .where(
                    variables.retrieveColumnForAlias( arguments.key ),
                    arguments.value
                );
        } );
        if ( !isNull( arguments.sortOrder ) ) {
            variables
                .retrieveQuery()
                .orderBy( arguments.sortOrder );
        }
        if ( !isNull( arguments.offset ) && arguments.offset > 0 ) {
            variables.retrieveQuery().offset( arguments.offset );
        }
        if ( !isNull( arguments.max ) && arguments.max > 0 ) {
            variables.retrieveQuery().limit( arguments.max );
        }
        if ( arguments.asQuery ) {
            return variables
                .retrieveQuery()
                .setReturnFormat( "query" )
                .get();
        } else {
            return super.get();
        }
    }

    public numeric function countWhere() {
        for ( var key in arguments ) {
            variables
                .retrieveQuery()
                .where(
                    variables.retrieveColumnForAlias( key ),
                    arguments[ key ]
                );
        }
        return variables.retrieveQuery().count();
    }

    public CBORMCompatEntity function deleteById( required any id ) {
        arguments.id = isArray( arguments.id ) ? arguments.id : [ arguments.id ];
        variables
            .retrieveQuery()
            .whereIn( get_key(), arguments.id )
            .delete();
        return this;
    }

    public struct function deleteWhere() {
        for ( var key in arguments ) {
            variables
                .retrieveQuery()
                .where(
                    variables.retrieveColumnForAlias( key ),
                    arguments[ key ]
                );
        }
        return super.deleteAll();
    }

    public boolean function exists( any id ) {
        if ( !isNull( arguments.id ) ) {
            variables
                .retrieveQuery()
                .where( get_key(), arguments.id );
        }
        return variables.retrieveQuery().exists();
    }

    public array function findAllWhere(
        required struct criteria = {},
        any sortOrder
    ) {
        structEach( arguments.criteria, function( key, value ) {
            variables
                .retrieveQuery()
                .where(
                    variables.retrieveColumnForAlias( arguments.key ),
                    arguments.value
                );
        } );
        if ( !isNull( arguments.sortOrder ) ) {
            var sorts = listToArray( arguments.sortOrder, "," ).map( function( sort ) {
                return replace( arguments.sort, " ", "|", "ALL" );
            } );
            variables.retrieveQuery().orderBy( sorts );
        }
        return super.get();
    }

    public any function findWhere( struct criteria = {} ) {
        structEach( arguments.criteria, function( key, value ) {
            variables
                .retrieveQuery()
                .where(
                    variables.retrieveColumnForAlias( arguments.key ),
                    arguments.value
                );
        } );
        return super.first();
    }

    public any function get( any id = 0, boolean returnNew = true ) {
        if (
            ( isNull( arguments.id ) || arguments.id == 0 ) && arguments.returnNew
        ) {
            return super.newEntity();
        }
        return invoke( this, "find", { id : arguments.id } );
    }

    public array function getAll( any id, any sortOrder ) {
        if ( isNull( arguments.id ) ) {
            if ( !isNull( arguments.sortOrder ) ) {
                var sorts = listToArray( arguments.sortOrder, "," ).map( function( sort ) {
                    return replace( arguments.sort, " ", "|", "ALL" );
                } );
                variables.retrieveQuery().orderBy( sorts );
            }
            return super.get();
        }
        var ids = isArray( arguments.id ) ? arguments.id : listToArray(
            arguments.id,
            ","
        );
        variables.retrieveQuery().whereIn( get_key(), ids );
        return super.get();
    }

    public any function new( struct properties = {} ) {
        return super.newEntity().fill( arguments.properties );
    }

    public CBORMCompatEntity function populate( struct properties = {} ) {
        super.fill( arguments.properties );
        return this;
    }

    public any function save( any entity ) {
        if ( isNull( arguments.entity ) ) {
            return super.save();
        }
        return arguments.entity.save();
    }

    public CBORMCompatEntity function saveAll( array entities = [] ) {
        arguments.entities.each( function( entity ) {
            arguments.entity.save();
        } );
        return this;
    }

    public CBORMCriteriaBuilderCompat function newCriteria() {
        return variables.CBORMCriteriaBuilderCompat
            .get()
            .setEntity( this );
    }

}
