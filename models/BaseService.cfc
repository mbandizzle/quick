component {

    property name="wirebox" inject="wirebox";
    property name="entity";

    public BaseService function init( required any entity ) {
        variables.entity = arguments.entity;
        return this;
    }

    public void function onDIComplete() {
        if ( isSimpleValue( variables.entity ) ) {
            variables.entity = variables.wirebox.getInstance( variables.entity );
        }
    }

    public any function onMissingMethod(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        return invoke(
            variables.entity.resetQuery(),
            arguments.missingMethodName,
            arguments.missingMethodArguments
        );
    }

}
