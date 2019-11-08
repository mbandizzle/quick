component extends="quick.models.Relationships.BaseRelationship" {

    function init( related, relationName, relationMethodName, parent, foreignKey, ownerKey ) {
        variables.ownerKey = arguments.ownerKey;
        variables.foreignKey = arguments.foreignKey;

        variables.child = arguments.parent;

        return super.init(
            arguments.related,
            arguments.relationName,
            arguments.relationMethodName,
            arguments.parent
        );
    }

    function getResults() {
        if ( variables.child.isNullAttribute( variables.foreignKey ) ) {
            return javacast( "null", "" );
        }
        return variables.related.first();
    }

    function addConstraints() {
        var table = variables.related.get_Table();
        variables.related.where(
            "#table#.#variables.ownerKey#",
            "=",
            variables.child.retrieveAttribute( variables.foreignKey )
        );
    }

    function addEagerConstraints( entities ) {
        var key = variables.related.get_Table() & "." & variables.ownerKey;
        variables.related.whereIn( key, variables.getEagerEntityKeys( arguments.entities ) );
    }

    function getEagerEntityKeys( entities ) {
        return arguments.entities.reduce( function( keys, entity ) {
            if ( ! isNull( arguments.entity.retrieveAttribute( variables.foreignKey ) ) ) {
                var key = arguments.entity.retrieveAttribute( variables.foreignKey );
                if ( key != "" ) {
                    arguments.keys.append( key );
                }
            }
            return arguments.keys;
        }, [] );
    }

    function initRelation( entities, relation ) {
        for ( var entity in arguments.entities ) {
            entity.assignRelationship( arguments.relation, javacast( "null", "" ) );
        }
        return arguments.entities;
    }

    function match( entities, results, relation ) {
        var dictionary = arguments.results.reduce( function( dict, result ) {
            arguments.dict[ arguments.result.retrieveAttribute( variables.ownerKey ) ] = arguments.result;
            return arguments.dict;
        }, {} );

        for ( var entity in arguments.entities ) {
            if ( structKeyExists( dictionary, entity.retrieveAttribute( variables.foreignKey ) ) ) {
                entity.assignRelationship( arguments.relation, dictionary[ entity.retrieveAttribute( variables.foreignKey ) ] );
            }
        }

        return arguments.entities;
    }

    function applySetter() {
        return variables.associate( argumentCollection = arguments );
    }

    function associate( entity ) {
        var ownerKeyValue = isSimpleValue( arguments.entity ) ?
            arguments.entity :
            arguments.entity.retrieveAttribute( variables.ownerKey );
        variables.child.forceAssignAttribute( variables.foreignKey, ownerKeyValue );
        if ( ! isSimpleValue( arguments.entity ) ) {
            variables.child.assignRelationship( variables.relationMethodName, arguments.entity );
        }
        return variables.child;
    }

    function dissociate() {
        variables.child.forceClearAttribute(
            name = variables.foreignKey,
            setToNull = true
        );
        return variables.child.clearRelationship( variables.relationMethodName );
    }

}
