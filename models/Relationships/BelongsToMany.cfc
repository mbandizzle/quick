component accessors="true" extends="quick.models.Relationships.BaseRelationship" {

    public BelongsToMany function init(
        required any related,
        required string relationName,
        required string relationMethodName,
        required any parent,
        required string table,
        required string foreignPivotKey,
        required string relatedPivotKey,
        required string parentKey,
        required string relatedKey
    ) {
        variables.table = arguments.table;
        variables.parentKey = arguments.parentKey;
        variables.relatedKey = arguments.relatedKey;
        variables.relatedPivotKey = arguments.relatedPivotKey;
        variables.foreignPivotKey = arguments.foreignPivotKey;

        return super.init(
            arguments.related,
            arguments.relationName,
            arguments.relationMethodName,
            arguments.parent
        );
    }

    public array function getResults() {
        return variables.related.get();
    }

    public void function addConstraints() {
        variables.performJoin();
        variables.addWhereConstraints();
    }

    public void function addEagerConstraints( required array entities ) {
        variables.related
            .from( variables.table )
            .whereIn(
                getQualifiedForeignPivotKeyName(),
                getKeys( arguments.entities, variables.parentKey )
            );
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
            if (
                structKeyExists(
                    dictionary,
                    entity.retrieveAttribute( variables.parentKey )
                )
            ) {
                entity.assignRelationship(
                    arguments.relation,
                    dictionary[ entity.retrieveAttribute( variables.parentKey ) ]
                );
            }
        }
        return arguments.entities;
    }

    public struct function buildDictionary( required array results ) {
        return arguments.results.reduce( function( dict, result ) {
            var key = arguments.result.retrieveAttribute(
                variables.foreignPivotKey
            );
            if ( !structKeyExists( arguments.dict, key ) ) {
                arguments.dict[ key ] = [];
            }
            arrayAppend( arguments.dict[ key ], arguments.result );
            return arguments.dict;
        }, {} );
    }

    public BelongsToMany function performJoin() {
        var baseTable = variables.related.get_table();
        var key = baseTable & "." & variables.relatedKey;
        variables.related.join(
            variables.table,
            key,
            "=",
            variables.getQualifiedRelatedPivotKeyName()
        );
        return this;
    }

    public BelongsToMany function addWhereConstraints() {
        variables.related.where(
            variables.getQualifiedForeignPivotKeyName(),
            "=",
            variables.parent.retrieveAttribute( variables.parentKey )
        );
        return this;
    }

    public string function getQualifiedRelatedPivotKeyName() {
        return variables.table & "." & variables.relatedPivotKey;
    }

    public string function getQualifiedForeignPivotKeyName() {
        return variables.table & "." & variables.foreignPivotKey;
    }

    public void function attach( required any id ) {
        variables
            .newPivotStatement()
            .insert( variables.parseIdsForInsert( arguments.id ) );
    }

    public void function detach( required any id ) {
        var foreignPivotKeyValue = variables.parent.retrieveAttribute(
            variables.parentKey
        );
        variables
            .newPivotStatement()
            .where( variables.foreignPivotKey, "=", foreignPivotKeyValue )
            .whereIn(
                variables.relatedPivotKey,
                variables.parseIds( arguments.id )
            )
            .delete();
    }

    public any function applySetter() {
        return variables.sync( argumentCollection = arguments );
    }

    public any function sync( required any id ) {
        var foreignPivotKeyValue = variables.parent.retrieveAttribute(
            variables.parentKey
        );
        variables
            .newPivotStatement()
            .where( variables.foreignPivotKey, "=", foreignPivotKeyValue )
            .delete();
        variables.attach( id );
        return variables.parent;
    }

    public QueryBuilder function newPivotStatement() {
        return variables.related
            .newQuery()
            .from( variables.table );
    }

    public array function parseIds( required any value ) {
        arguments.value = isArray( arguments.value ) ? arguments.value : [
            arguments.value
        ];
        return arguments.value.map( function( val ) {
            // If the value is not a simple value, we will assume
            // it is an entity and return its key value.
            if ( !isSimpleValue( arguments.val ) ) {
                return arguments.val.keyValue();
            }
            return arguments.val;
        } );
    }

    public array function parseIdsForInsert( required any value ) {
        var foreignPivotKeyValue = variables.parent.retrieveAttribute(
            variables.parentKey
        );
        arguments.value = isArray( arguments.value ) ? arguments.value : [
            arguments.value
        ];
        return arguments.value.map( function( val ) {
            // If the value is not a simple value, we will assume
            // it is an entity and return its key value.
            if ( !isSimpleValue( arguments.val ) ) {
                arguments.val = arguments.val.keyValue();
            }
            var insertRecord = {};
            insertRecord[ variables.foreignPivotKey ] = foreignPivotKeyValue;
            insertRecord[ variables.relatedPivotKey ] = arguments.val;
            return insertRecord;
        } );
    }

}
