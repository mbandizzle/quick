component extends="quick.models.Relationships.BelongsTo" {

    function init( related, relationName, relationMethodName, parent, foreignKey, ownerKey, type ) {
        variables.morphType = arguments.type;

        return super.init(
            arguments.related,
            arguments.relationName,
            arguments.relationMethodName,
            arguments.parent,
            arguments.foreignKey,
            arguments.ownerKey
        );
    }

    function addEagerConstraints( entities ) {
        variables.entities = arguments.entities;
        variables.buildDictionary( variables.entities );
    }

    function buildDictionary( entities ) {
        variables.dictionary = arguments.entities.reduce( function( dict, entity ) {
            var type = arguments.entity.retrieveAttribute( variables.morphType );
            if ( ! structKeyExists( arguments.dict, type ) )  {
                arguments.dict[ type ] = {};
            }
            var key = arguments.entity.retrieveAttribute( variables.foreignKey );
            if ( ! structKeyExists( arguments.dict[ type ], key ) )  {
                arguments.dict[ type ][ key ] = [];
            }
            arrayAppend( arguments.dict[ type ][ key ], arguments.entity );
            return arguments.dict;
        }, {} );
    }

    function getResults() {
        return variables.ownerKey != "" ? super.getResults() : {};
    }

    function getEager() {
        structKeyArray( variables.dictionary ).each( function( type ) {
            variables.matchToMorphParents(
               arguments.type,
               variables.getResultsByType( arguments.type )
            );
        } );

        return variables.entities;
    }

    function getResultsByType( type ) {
        var instance = createModelByType( arguments.type );
        var localOwnerKey = variables.ownerKey != "" ? variables.ownerKey : instance.get_Key();
        instance.with( variables.related.get_eagerLoad() );

        return instance.whereIn(
            instance.get_table() & "." & localOwnerKey,
            variables.gatherKeysByType( type )
        ).get();
    }

    function gatherKeysByType( type ) {
        return unique( structReduce( variables.dictionary[ arguments.type ], function( acc, key, values ) {
            arrayAppend( arguments.acc, arguments.values[ 1 ].retrieveAttribute( variables.foreignKey ) );
            return arguments.acc;
        }, [] ) );
    }

    function createModelByType( type ) {
        return variables.wirebox.getInstance( arguments.type );
    }

    function matchToMorphParents( type, results ) {
        for ( var result in arguments.results ) {
            var ownerKeyValue = variables.ownerKey != "" ? result.retrieveAttribute( variables.ownerKey ) : result.keyValue();
            if ( structKeyExists( variables.dictionary[ arguments.type ], ownerKeyValue ) ) {
                var entities = variables.dictionary[ arguments.type ][ ownerKeyValue ];
                entities.each( function( entity ) {
                    entity.assignRelationship( variables.relationMethodName, result );
                } );
            }
        }
    }

}
