component {

    property name="wirebox" inject="wirebox";

    public BaseRelationship function init(
        required any related,
        required string relationName,
        required string relationMethodName,
        required any parent
    ) {
        variables.related = arguments.related.resetQuery();
        variables.relationName = arguments.relationName;
        variables.relationMethodName = arguments.relationMethodName;
        variables.parent = arguments.parent;

        variables.addConstraints();

        return this;
    }

    public BaseRelationship function setRelationMethodName( required string name ) {
        variables.relationMethodName = arguments.name;
        return this;
    }

    public array function getEager() {
        return variables.related.get();
    }

    public any function first() {
        return variables.related.first();
    }

    public any function firstOrFail() {
        return variables.related.firstOrFail();
    }

    public any function find( required any id ) {
        return variables.related.find( arguments.id );
    }

    public any function findOrFail( required any id ) {
        return variables.related.findOrFail( arguments.id );
    }

    public array function all() {
        return variables.related.all();
    }

    /**
    * get()
    * @hint wrapper for getResults() on relationship types that have them, which is most of them. get() implemented for consistency with QB and Quick
    */
    public any function get() {
        return variables.getResults();
    }

    public array function getKeys( required array entities, required string key ) {
        var keys = [];
        for ( var entity in arguments.entities ) {
            keys.append( entity.retrieveAttribute( arguments.key ) );
        }
        return unique( keys );
    }

    public any function onMissingMethod(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        var result = invoke(
            variables.related,
            arguments.missingMethodName,
            arguments.missingMethodArguments
        );
        if ( isSimpleValue( result ) ) {
            return result;
        }
        return this;
    }

    public array function unique( required array items ) {
        return arraySlice( createObject( "java", "java.util.HashSet" ).init( arguments.items ).toArray(), 1 );
    }

}
