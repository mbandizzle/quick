component {

    function new( entity ) {
        return arguments.entity.get_wirebox().getInstance(
            name = arguments.entity.get_fullName(),
            initArguments = { meta = arguments.entity.get_meta() }
        );
    }

}
