component {

    property name="wirebox" inject="wirebox";
    property name="entity";

    function init( entity ) {
        variables.entity = arguments.entity;
        return this;
    }

    function onDIComplete() {
        if ( isSimpleValue( variables.entity ) ) {
            variables.entity = variables.wirebox.getInstance( variables.entity );
        }
    }

    function onMissingMethod( missingMethodName, missingMethodArguments ) {
        return invoke(
            variables.entity.resetQuery(),
            arguments.missingMethodName,
            arguments.missingMethodArguments
        );
    }

}
