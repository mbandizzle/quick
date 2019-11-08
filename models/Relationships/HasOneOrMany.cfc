component extends="quick.models.Relationships.BaseRelationship" accessors="true" {

    public HasOneOrMany function init(
        required any related,
        required string relationName,
        required string relationMethodName,
        required any parent,
        required string foreignKey,
        required string localKey
    ) {
        variables.localKey = arguments.localKey;
        variables.foreignKey = arguments.foreignKey;

        return super.init(
            arguments.related,
            arguments.relationName,
            arguments.relationMethodName,
            arguments.parent
        );
    }

    public HasOneOrMany function addConstraints() {
        variables.related
            .retrieveQuery()
            .where( variables.foreignKey, "=", variables.getParentKey() )
            .whereNotNull( variables.foreignKey );
        return this;
    }

    public HasOneOrMany function addEagerConstraints( required array entities ) {
        variables.related
            .retrieveQuery()
            .whereIn(
                variables.foreignKey,
                variables.getKeys( arguments.entities, variables.localKey )
            );
        return this;
    }

    public array function matchOne(
        required array entities,
        required array results,
        required string relation
    ) {
        arguments.type = "one";
        return matchOneOrMany( argumentCollection = arguments );
    }

    public array function matchMany(
        required array entities,
        required array results,
        required string relation
    ) {
        arguments.type = "many";
        return matchOneOrMany( argumentCollection = arguments );
    }

    public array function matchOneOrMany(
        required array entities,
        required array results,
        required string relation,
        required string type
    ) {
        var dictionary = buildDictionary( arguments.results );
        for ( var entity in arguments.entities ) {
            var key = entity.retrieveAttribute( variables.localKey );
            if ( structKeyExists( dictionary, key ) ) {
                entity.assignRelationship(
                    arguments.relation,
                    variables.getRelationValue(
                        dictionary,
                        key,
                        arguments.type
                    )
                );
            }
        }
        return arguments.entities;
    }

    public struct function buildDictionary( required array results ) {
        return arguments.results.reduce( function( dict, result ) {
            var key = arguments.result.retrieveAttribute(
                variables.foreignKey
            );
            if ( !structKeyExists( arguments.dict, key ) ) {
                arguments.dict[ key ] = [];
            }
            arrayAppend( arguments.dict[ key ], arguments.result );
            return arguments.dict;
        }, {} );
    }

    public any function getRelationValue(
        required struct dictionary,
        required string key,
        required string type
    ) {
        var value = arguments.dictionary[ arguments.key ];
        return arguments.type == "one" ? value[ 1 ] : value;
    }

    public any function getParentKey() {
        return variables.parent.retrieveAttribute( variables.localKey );
    }

    public array function applySetter() {
        variables.related.updateAll(
            attributes = {
                "#variables.foreignKey#" : {
                    "value" : "",
                    "cfsqltype" : "varchar",
                    "null" : true,
                    "nulls" : true
                }
            },
            force = true
        );
        return variables.saveMany( argumentCollection = arguments );
    }

    public array function saveMany( required any entities ) {
        arguments.entities = isArray( arguments.entities ) ? arguments.entities : [
            arguments.entities
        ];
        return arguments.entities.map( function( entity ) {
            return variables.save( arguments.entity );
        } );
    }

    public any function save( required any entity ) {
        if ( isSimpleValue( arguments.entity ) ) {
            arguments.entity = variables.related
                .newEntity()
                .set_loaded( true )
                .forceAssignAttribute(
                    variables.related.get_key(),
                    arguments.entity
                );
        }
        variables.setForeignAttributesForCreate( arguments.entity );
        return arguments.entity.save();
    }

    public any function create( struct attributes = {} ) {
        var newInstance = variables.related
            .newEntity()
            .fill( arguments.attributes );
        variables.setForeignAttributesForCreate( newInstance );
        return newInstance.save();
    }

    public HasOneOrMany function setForeignAttributesForCreate(
        required any entity
    ) {
        arguments.entity.forceAssignAttribute(
            variables.getForeignKeyName(),
            variables.getParentKey()
        );
        return this;
    }

    public string function getForeignKeyName() {
        var parts = listToArray( variables.getQualifiedForeignKeyName(), "." );
        return parts[ arrayLen( parts ) ];
    }

    public string function getQualifiedForeignKeyName() {
        return variables.foreignKey;
    }

}
