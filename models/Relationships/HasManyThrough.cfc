component accessors="true" extends="quick.models.Relationships.BaseRelationship" {

    function init(
        related,
        relationName,
        relationMethodName,
        parent,
        intermediate,
        firstKey,
        secondKey,
        localKey,
        secondLocalKey
    ) {
        variables.throughParent = arguments.intermediate;
        variables.farParent = arguments.parent;

        variables.firstKey = arguments.firstKey;
        variables.secondKey = arguments.secondKey;
        variables.localKey = arguments.localKey;
        variables.secondLocalKey = arguments.secondLocalKey;

        return super.init(
            arguments.related,
            arguments.relationName,
            arguments.relationMethodName,
            arguments.intermediate
        );
    }

    function addConstraints() {
        var localValue = variables.farParent.retrieveAttribute( variables.localKey );
        variables.performJoin();
        variables.related.where(
            variables.getQualifiedFirstKeyName(),
            "=",
            localValue
        );
    }

    function performJoin() {
        var farKey = variables.getQualifiedFarKeyName();
        variables.related.join(
            variables.throughParent.get_Table(),
            variables.getQualifiedParentKeyName(),
            "=",
            farKey
        );
    }

    function getQualifiedFarKeyName() {
        return variables.getQualifiedForeignKeyName();
    }

    function getQualifiedForeignKeyName() {
        return variables.related.qualifyColumn( variables.secondKey );
    }

    function getQualifiedFirstKeyName() {
        return variables.throughParent.qualifyColumn( variables.firstKey );
    }

    function getQualifiedParentKeyName() {
        return variables.parent.qualifyColumn( variables.secondLocalKey );
    }

    function getResults() {
        return variables.get();
    }

    function get() {
        var entities = variables.related.getEntities();
        if ( entities.len() > 0 ) {
            entities = variables.related.eagerLoadRelations( entities );
        }
        return entities;
    }

    function addEagerConstraints( entities ) {
        variables.performJoin();
        variables.related.whereIn(
            variables.getQualifiedFirstKeyName(),
            variables.getKeys( arguments.entities, variables.localKey )
        );
    }

    function initRelation( entities, relation ) {
        for ( var entity in arguments.entities ) {
            entity.assignRelationship( arguments.relation, [] );
        }
        return arguments.entities;
    }

    function match( entities, results, relation ) {
        var dictionary = buildDictionary( arguments.results );
        for ( var entity in arguments.entities ) {
            var key = entity.retrieveAttribute( variables.localKey );
            if ( structKeyExists( dictionary, key ) ) {
                entity.assignRelationship( arguments.relation, dictionary[ key ] );
            }
        }
        return arguments.entities;
    }

    function buildDictionary( results ) {
        return arguments.results.reduce( function( dict, result ) {
            var key = arguments.result.retrieveAttribute( variables.firstKey );
            if ( ! structKeyExists( arguments.dict, key ) ) {
                arguments.dict[ key ] = [];
            }
            arrayAppend( arguments.dict[ key ], arguments.result );
            return arguments.dict;
        }, {} );
    }

}
