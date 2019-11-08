component {

    public QuickServiceDSL function init( required Injector injector ) {
        variables.injector = arguments.injector;
        return this;
    }

    public BaseService function process(
        required struct definition,
        any targetObject
    ) {
        return variables.injector.getInstance(
            name = "BaseService@quick",
            initArguments = {
                entity : variables.injector.getInstance(
                    listRest( arguments.definition.dsl, ":" )
                )
            }
        );
    }

}
