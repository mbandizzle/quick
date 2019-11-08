component extends="quick.models.Relationships.BelongsTo" {

    public PolymorphicBelongsTo function init(
        required any related,
        required string relationName,
        required string relationMethodName,
        required any parent,
        required string foreignKey,
        required string ownerKey,
        required string type
    ) {
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

    public PolymorphicBelongsTo function addEagerConstraints(
        required array entities
    ) {
        variables.entities = arguments.entities;
        variables.buildDictionary( variables.entities );
        return this;
    }

    public struct function buildDictionary( required array entities ) {
        variables.dictionary = arguments.entities.reduce( function( dict, entity ) {
            var type = arguments.entity.retrieveAttribute(
                variables.morphType
            );
            if ( !structKeyExists( arguments.dict, type ) ) {
                arguments.dict[ type ] = {};
            }
            var key = arguments.entity.retrieveAttribute(
                variables.foreignKey
            );
            if ( !structKeyExists( arguments.dict[ type ], key ) ) {
                arguments.dict[ type ][ key ] = [];
            }
            arrayAppend( arguments.dict[ type ][ key ], arguments.entity );
            return arguments.dict;
        }, {} );
        return variables.dictionary;
    }

    public any function getResults() {
        return variables.ownerKey != "" ? super.getResults() : {};
    }

    public array function getEager() {
        structKeyArray( variables.dictionary ).each( function( type ) {
            variables.matchToMorphParents(
                arguments.type,
                variables.getResultsByType( arguments.type )
            );
        } );

        return variables.entities;
    }

    public any function getResultsByType( required string type ) {
        var instance = createModelByType( arguments.type );
        var localOwnerKey = variables.ownerKey != "" ? variables.ownerKey : instance.get_Key();
        instance.with( variables.related.get_eagerLoad() );

        return instance
            .whereIn(
                instance.get_table() & "." & localOwnerKey,
                variables.gatherKeysByType( type )
            )
            .get();
    }

    public array function gatherKeysByType( required string type ) {
        return unique(
            structReduce(
                variables.dictionary[ arguments.type ],
                function( acc, key, values ) {
                    arrayAppend(
                        arguments.acc,
                        arguments.values[ 1 ].retrieveAttribute(
                            variables.foreignKey
                        )
                    );
                    return arguments.acc;
                },
                []
            )
        );
    }

    public any function createModelByType( required string type ) {
        return variables.wirebox.getInstance( arguments.type );
    }

    public PolymorphicBelongsTo function matchToMorphParents(
        required string type,
        required array results
    ) {
        for ( var result in arguments.results ) {
            var ownerKeyValue = variables.ownerKey != "" ? result.retrieveAttribute(
                variables.ownerKey
            ) : result.keyValue();
            if (
                structKeyExists(
                    variables.dictionary[ arguments.type ],
                    ownerKeyValue
                )
            ) {
                var entities = variables.dictionary[ arguments.type ][
                    ownerKeyValue
                ];
                entities.each( function( entity ) {
                    entity.assignRelationship(
                        variables.relationMethodName,
                        result
                    );
                } );
            }
        }
        return this;
    }

}
