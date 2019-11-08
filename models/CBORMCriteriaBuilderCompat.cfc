component accessors="true" {

    property name="entity";

    public CBORMCriteriaBuilderCompat function init( any entity entity ) {
        if ( ! isNull( arguments.entity ) ) {
            variables.entity = arguments.entity;
        }
        return this;
    }

    public string function getSQL() {
        return variables.entity.retrieveQuery().toSQL();
    }

    public CBORMCriteriaBuilderCompat function between(
        required string column,
        required any start,
        required any end
    ) {
        variables.entity
            .retrieveQuery()
            .whereBetween( arguments.column, arguments.start, arguments.end );
        return this;
    }

    public CBORMCriteriaBuilderCompat function eqProperty(
        required string left,
        required string right
    ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, arguments.right );
        return this;
    }

    public CBORMCriteriaBuilderCompat function isEQ(
        required string column,
        required any value
    ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "=", arguments.value );
        return this;
    }

    public CBORMCriteriaBuilderCompat function isGT(
        required string column,
        required any value
    ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, ">", arguments.value );
        return this;
    }

    public CBORMCriteriaBuilderCompat function gtProperty(
        required string left,
        required string right
    ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, ">", arguments.right );
        return this;
    }

    public CBORMCriteriaBuilderCompat function isGE(
        required string column,
        required any value
    ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, ">=", arguments.value );
        return this;
    }

    public CBORMCriteriaBuilderCompat function geProperty(
        required string left,
        required string right
    ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, ">=", arguments.right );
        return this;
    }

    public CBORMCriteriaBuilderCompat function idEQ( required any id ) {
        variables.entity
            .retrieveQuery()
            .where( variables.entity.get_key(), arguments.id );
        return this;
    }

    public CBORMCriteriaBuilderCompat function like(
        required string column,
        required any value
    ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "like", arguments.value );
        return this;
    }

    public CBORMCriteriaBuilderCompat function ilike(
        required string column,
        required any value
    ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "ilike", arguments.value );
        return this;
    }

    public CBORMCriteriaBuilderCompat function isIn(
        required string column,
        required any values
    ) {
        variables.entity
            .retrieveQuery()
            .whereIn( arguments.column, arguments.values );
        return this;
    }

    public CBORMCriteriaBuilderCompat function isNull( required string column ) {
        variables.entity.retrieveQuery().whereNull( column );
        return this;
    }

    public CBORMCriteriaBuilderCompat function isNotNull( required string column ) {
        variables.entity
            .retrieveQuery()
            .whereNotNull( arguments.column );
        return this;
    }

    public CBORMCriteriaBuilderCompat function isLT(
        required string column,
        required any value
    ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "<", arguments.value );
        return this;
    }

    public CBORMCriteriaBuilderCompat function ltProperty(
        required string left,
        required string right
    ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, "<", arguments.right );
        return this;
    }

    public CBORMCriteriaBuilderCompat function neProperty(
        required string left,
        required string right
    ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, "<>", arguments.right );
        return this;
    }

    public CBORMCriteriaBuilderCompat function isLE(
        required string column,
        required any value
    ) {
        variables.entity
            .retrieveQuery()
            .where( arguments.column, "<=", arguments.value );
        return this;
    }

    public CBORMCriteriaBuilderCompat function leProperty(
        required string left,
        required string right
    ) {
        variables.entity
            .retrieveQuery()
            .whereColumn( arguments.left, "<=", arguments.right );
        return this;
    }

    public CBORMCriteriaBuilderCompat function maxResults( required numeric max ) {
        variables.entity
            .retrieveQuery()
            .limit( arguments.max );
        return this;
    }

    public CBORMCriteriaBuilderCompat function firstResult( required numeric offset ) {
        variables.entity
            .retrieveQuery()
            .offset( arguments.offset );
        return this;
    }

    public CBORMCriteriaBuilderCompat function order( required any orders ) {
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

    public array function list() {
        return variables.entity.getAll();
    }

    public any function get() {
        return variables.entity.first();
    }

    public numeric function count() {
        return variables.entity.count();
    }

    public CBORMCriteriaBuilderCompat function onMissingMethod(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        invoke( variables.query, arguments.missingMethodName, arguments.missingMethodArguments );
        return this;
    }

}
