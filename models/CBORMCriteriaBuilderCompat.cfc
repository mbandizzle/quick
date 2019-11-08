component accessors="true" {

    property name="entity";

    function init( entity, query ) {
        if ( ! isNull( arguments.entity ) ) {
            variables.entity = arguments.entity;
        }
        return this;
    }

    function getSQL() {
        return variables.entity.retrieveQuery().toSQL();
    }

    function between( column, start, end ) {
        variables.entity
            .retrieveQuery()
            .whereBetween( arguments.column, arguments.start, arguments.end );
        return this;
    }

    function eqProperty( left, right ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, arguments.right );
        return this;
    }

    function isEQ( column, value ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "=", arguments.value );
        return this;
    }

    function isGT( column, value ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, ">", arguments.value );
        return this;
    }

    function gtProperty( left, right ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, ">", arguments.right );
        return this;
    }

    function isGE( column, value ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, ">=", arguments.value );
        return this;
    }

    function geProperty( left, right ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, ">=", arguments.right );
        return this;
    }

    function idEQ( id ) {
        variables.entity
            .retrieveQuery()
            .where( variables.entity.get_key(), arguments.id );
        return this;
    }

    function like( column, value ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "like", arguments.value );
        return this;
    }

    function ilike( column, value ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "ilike", arguments.value );
        return this;
    }

    function isIn( column, values ) {
        variables.entity
            .retrieveQuery()
            .whereIn( arguments.column, arguments.values );
        return this;
    }

    function isNull( column ) {
        variables.entity.retrieveQuery().whereNull( column );
        return this;
    }

    function isNotNull( column ) {
        variables.entity
            .retrieveQuery()
            .whereNotNull( arguments.column );
        return this;
    }

    function isLT( column, value ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "<", arguments.value );
        return this;
    }

    function ltProperty( left, right ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, "<", arguments.right );
        return this;
    }

    function neProperty( left, right ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, "<>", arguments.right );
        return this;
    }

    function isLE( column, value ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "<=", arguments.value );
        return this;
    }

    function leProperty( left, right ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, "<=", arguments.right );
        return this;
    }

    function maxResults( max ) {
        variables.entity
            .retrieveQuery()
            .limit( arguments.max );
        return this;
    }

    function firstResult( offset ) {
        variables.entity
            .retrieveQuery()
            .offset( arguments.offset );
        return this;
    }

    function order( orders ) {
        arguments.orders = isArray( arguments.orders ) ?
            arguments.orders :
            listToArray( arguments.orders, "," );
        variables.entity.retrieveQuery().orderBy(
            arguments.orders.map( function( order ) {
                return replace( arguments.order, " ", "|" );
            } )
        );
        return this;
    }

    function list() {
        return variables.entity.getAll();
    }

    function get() {
        return variables.entity.first();
    }

    function count() {
        return variables.entity.count();
    }

    function onMissingMethod( missingMethodName, missingMethodArguments ) {
        invoke( variables.query, arguments.missingMethodName, arguments.missingMethodArguments );
        return this;
    }

}
