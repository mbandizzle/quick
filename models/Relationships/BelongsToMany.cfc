component accessors="true" extends="quick.models.Relationships.BaseRelationship" {

    function init(
        related,
        relationName,
        relationMethodName,
        parent,
        table,
        foreignPivotKey,
        relatedPivotKey,
        parentKey,
        relatedKey
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

    function getResults() {
        return variables.related.get();
    }

    function addConstraints() {
        variables.performJoin();
        variables.addWhereConstraints();
    }

    function addEagerConstraints( entities ) {
        variables.related
            .from( variables.table )
            .whereIn(
                getQualifiedForeignPivotKeyName(),
                getKeys( arguments.entities, variables.parentKey )
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
            if ( structKeyExists( dictionary, entity.retrieveAttribute( variables.parentKey ) ) ) {
                entity.assignRelationship(
                    arguments.relation,
                    dictionary[ entity.retrieveAttribute( variables.parentKey ) ]
                );
            }
        }
        return arguments.entities;
    }

    function buildDictionary( results ) {
        return arguments.results.reduce( function( dict, result ) {
            var key = arguments.result.retrieveAttribute( variables.foreignPivotKey );
            if ( ! structKeyExists( arguments.dict, key ) ) {
                arguments.dict[ key ] = [];
            }
            arrayAppend( arguments.dict[ key ], arguments.result );
            return arguments.dict;
        }, {} );
    }

    function performJoin() {
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

    function addWhereConstraints() {
        variables.related.where(
            variables.getQualifiedForeignPivotKeyName(),
            "=",
            variables.parent.retrieveAttribute( variables.parentKey )
        );
        return this;
    }

    function getQualifiedRelatedPivotKeyName() {
        return variables.table & "." & variables.relatedPivotKey;
    }

    function getQualifiedForeignPivotKeyName() {
        return variables.table & "." & variables.foreignPivotKey;
    }

    function attach( id ) {
        variables.newPivotStatement()
            .insert( variables.parseIdsForInsert( arguments.id ) );
    }

    function detach( id ) {
        var foreignPivotKeyValue = variables.parent.retrieveAttribute( variables.parentKey );
        variables.newPivotStatement()
            .where( variables.foreignPivotKey, "=", foreignPivotKeyValue )
            .whereIn(
                variables.relatedPivotKey,
                variables.parseIds( arguments.id )
            ).delete();
    }

    function applySetter() {
        return variables.sync( argumentCollection = arguments );
    }

    function sync( id ) {
        var foreignPivotKeyValue = variables.parent.retrieveAttribute( variables.parentKey );
        variables.newPivotStatement()
            .where( variables.foreignPivotKey, "=", foreignPivotKeyValue )
            .delete();
        variables.attach( id );
        return variables.parent;
    }

    function newPivotStatement() {
        return variables.related.newQuery().from( variables.table );
    }

    function parseIds( value ) {
        arguments.value = isArray( arguments.value ) ? arguments.value : [ arguments.value ];
        return arguments.value.map( function( val ) {
            // If the value is not a simple value, we will assume
            // it is an entity and return its key value.
            if ( ! isSimpleValue( arguments.val ) ) {
                return arguments.val.keyValue();
            }
            return arguments.val;
        } );
    }

    function parseIdsForInsert( value ) {
        var foreignPivotKeyValue = variables.parent.retrieveAttribute( variables.parentKey );
        arguments.value = isArray( arguments.value ) ? arguments.value : [ arguments.value ];
        return arguments.value.map( function( val ) {
            // If the value is not a simple value, we will assume
            // it is an entity and return its key value.
            if ( ! isSimpleValue( arguments.val ) ) {
                arguments.val = arguments.val.keyValue();
            }
            var insertRecord = {};
            insertRecord[ variables.foreignPivotKey ] = foreignPivotKeyValue;
            insertRecord[ variables.relatedPivotKey ] = arguments.val;
            return insertRecord;
        } );
    }

}
