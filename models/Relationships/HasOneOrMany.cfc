component extends="quick.models.Relationships.BaseRelationship" accessors="true" {

    function init( related, relationName, relationMethodName, parent, foreignKey, localKey ) {
        variables.localKey = arguments.localKey;
        variables.foreignKey = arguments.foreignKey;

        return super.init(
            arguments.related,
            arguments.relationName,
            arguments.relationMethodName,
            arguments.parent
        );
    }

    function addConstraints() {
        variables.related.retrieveQuery()
            .where( variables.foreignKey, "=", variables.getParentKey() )
            .whereNotNull( variables.foreignKey );
    }

    function addEagerConstraints( entities ) {
        variables.related.retrieveQuery().whereIn(
            variables.foreignKey,
            variables.getKeys( arguments.entities, variables.localKey )
        );
    }

    function matchOne( entities, results, relation ) {
        arguments.type = "one";
        return matchOneOrMany( argumentCollection = arguments );
    }

    function matchMany( entities, results, relation ) {
        arguments.type = "many";
        return matchOneOrMany( argumentCollection = arguments );
    }

    function matchOneOrMany( entities, results, relation, type ) {
        var dictionary = buildDictionary( arguments.results );
        for ( var entity in arguments.entities ) {
            var key = entity.retrieveAttribute( variables.localKey );
            if ( structKeyExists( dictionary, key ) ) {
                entity.assignRelationship(
                    arguments.relation,
                    variables.getRelationValue( dictionary, key, arguments.type )
                );
            }
        }
        return arguments.entities;
    }

    function buildDictionary( results ) {
        return arguments.results.reduce( function( dict, result ) {
            var key = arguments.result.retrieveAttribute( variables.foreignKey );
            if ( ! structKeyExists( arguments.dict, key ) ) {
                arguments.dict[ key ] = [];
            }
            arrayAppend( arguments.dict[ key ], arguments.result );
            return arguments.dict;
        }, {} );
    }

    function getRelationValue( dictionary, key, type ) {
        var value = arguments.dictionary[ arguments.key ];
        return arguments.type == "one" ? value[ 1 ] : value;
    }

    function getParentKey() {
        return variables.parent.retrieveAttribute( variables.localKey );
    }

    function applySetter() {
        variables.related.updateAll(
            attributes = {
                "#variables.foreignKey#" = { "value" = "", "cfsqltype" = "varchar", "null" = true, "nulls" = true }
            },
            force = true
        );
        return variables.saveMany( argumentCollection = arguments );
    }

    function saveMany( entities ) {
        arguments.entities = isArray( arguments.entities ) ? arguments.entities : [ arguments.entities ];
        return arguments.entities.map( function( entity ) {
            return variables.save( arguments.entity );
        } );
    }

    function save( entity ) {
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

    function create( attributes = {} ) {
        var newInstance = variables.related.newEntity().fill( arguments.attributes );
        variables.setForeignAttributesForCreate( newInstance );
        return newInstance.save();
    }

    function setForeignAttributesForCreate( entity ) {
        arguments.entity.forceAssignAttribute(
            variables.getForeignKeyName(),
            variables.getParentKey()
        );
    }

    function getForeignKeyName() {
        var parts = listToArray( variables.getQualifiedForeignKeyName(), "." );
        return parts[ arrayLen( parts ) ];
    }

    function getQualifiedForeignKeyName() {
        return variables.foreignKey;
    }

}
