component extends="quick.models.Relationships.BaseRelationship" {

    public BelongsTo function init(
        required any related,
        required string relationName,
        required string relationMethodName,
        required any parent,
        required string foreignKey,
        required string ownerKey
    ) {
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

    public any function getResults() {
        if ( variables.child.isNullAttribute( variables.foreignKey ) ) {
            return javacast( "null", "" );
        }
        return variables.related.first();
    }

    public void function addConstraints() {
        var table = variables.related.get_Table();
        variables.related.where(
            "#table#.#variables.ownerKey#",
            "=",
            variables.child.retrieveAttribute( variables.foreignKey )
        );
    }

    public void function addEagerConstraints( required array entities ) {
        var key = variables.related.get_Table() & "." & variables.ownerKey;
        variables.related.whereIn(
            key,
            variables.getEagerEntityKeys( arguments.entities )
        );
    }

    public array function getEagerEntityKeys( required array entities ) {
        return arguments.entities.reduce( function( keys, entity ) {
            if (
                !isNull(
                    arguments.entity.retrieveAttribute(
                        variables.foreignKey
                    )
                )
            ) {
                var key = arguments.entity.retrieveAttribute(
                    variables.foreignKey
                );
                if ( key != "" ) {
                    arguments.keys.append( key );
                }
            }
            return arguments.keys;
        }, [] );
    }

    public array function initRelation(
        required array entities,
        required string relation
    ) {
        for ( var entity in arguments.entities ) {
            entity.assignRelationship(
                arguments.relation,
                javacast( "null", "" )
            );
        }
        return arguments.entities;
    }

    public array function match(
        required array entities,
        required array results,
        required string relation
    ) {
        var dictionary = arguments.results.reduce( function( dict, result ) {
            arguments.dict[
                arguments.result.retrieveAttribute( variables.ownerKey )
            ] = arguments.result;
            return arguments.dict;
        }, {} );

        for ( var entity in arguments.entities ) {
            if (
                structKeyExists(
                    dictionary,
                    entity.retrieveAttribute( variables.foreignKey )
                )
            ) {
                entity.assignRelationship(
                    arguments.relation,
                    dictionary[ entity.retrieveAttribute( variables.foreignKey ) ]
                );
            }
        }

        return arguments.entities;
    }

    public any function applySetter() {
        return variables.associate( argumentCollection = arguments );
    }

    public any function associate( required any entity ) {
        var ownerKeyValue = isSimpleValue( arguments.entity ) ? arguments.entity : arguments.entity.retrieveAttribute(
            variables.ownerKey
        );
        variables.child.forceAssignAttribute(
            variables.foreignKey,
            ownerKeyValue
        );
        if ( !isSimpleValue( arguments.entity ) ) {
            variables.child.assignRelationship(
                variables.relationMethodName,
                arguments.entity
            );
        }
        return variables.child;
    }

    public any function dissociate() {
        variables.child.forceClearAttribute(
            name = variables.foreignKey,
            setToNull = true
        );
        return variables.child.clearRelationship(
            variables.relationMethodName
        );
    }

}
