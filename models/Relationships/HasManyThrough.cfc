component accessors="true" extends="quick.models.Relationships.BaseRelationship" {

    public HasManyThrough function init(
        required any related,
        required string relationName,
        required string relationMethodName,
        required any parent,
        required any intermediate,
        required string firstKey,
        required string secondKey,
        required string localKey,
        required string secondLocalKey
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

    public void function addConstraints() {
        var localValue = variables.farParent.retrieveAttribute( variables.localKey );
        variables.performJoin();
        variables.related.where(
            variables.getQualifiedFirstKeyName(),
            "=",
            localValue
        );
    }

    public HasManyThrough function performJoin() {
        var farKey = variables.getQualifiedFarKeyName();
        variables.related.join(
            variables.throughParent.get_Table(),
            variables.getQualifiedParentKeyName(),
            "=",
            farKey
        );
        return this;
    }

    public string function getQualifiedFarKeyName() {
        return variables.getQualifiedForeignKeyName();
    }

    public string function getQualifiedForeignKeyName() {
        return variables.related.qualifyColumn( variables.secondKey );
    }

    public string function getQualifiedFirstKeyName() {
        return variables.throughParent.qualifyColumn( variables.firstKey );
    }

    public string function getQualifiedParentKeyName() {
        return variables.parent.qualifyColumn( variables.secondLocalKey );
    }

    public array function getResults() {
        return variables.get();
    }

    public array function get() {
        var entities = variables.related.getEntities();
        if ( entities.len() > 0 ) {
            entities = variables.related.eagerLoadRelations( entities );
        }
        return entities;
    }

    public HasManyThrough function addEagerConstraints( required array entities ) {
        variables.performJoin();
        variables.related.whereIn(
            variables.getQualifiedFirstKeyName(),
            variables.getKeys( arguments.entities, variables.localKey )
        );
        return this;
    }

    public array function initRelation(
        required array entities,
        required string relation
    ) {
        for ( var entity in arguments.entities ) {
            entity.assignRelationship( arguments.relation, [] );
        }
        return arguments.entities;
    }

    public array function match(
        required array entities,
        required array results,
        required string relation
    ) {
        var dictionary = buildDictionary( arguments.results );
        for ( var entity in arguments.entities ) {
            var key = entity.retrieveAttribute( variables.localKey );
            if ( structKeyExists( dictionary, key ) ) {
                entity.assignRelationship( arguments.relation, dictionary[ key ] );
            }
        }
        return arguments.entities;
    }

    public struct function buildDictionary( required array results ) {
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
