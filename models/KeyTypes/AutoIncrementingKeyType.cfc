component implements="KeyType" {

    /**
     * Called to handle any tasks before inserting into the database.
     * Receives the entity as the only argument.
     */
    public void function preInsert( required entity ) {
        return;
    }

    /**
     * Called to handle any tasks after inserting into the database.
     * Receives the entity and the queryExecute result as arguments.
     */
    public void function postInsert( required entity, required struct result ) {
        var generatedKey = arguments.result.result.keyExists( arguments.entity.get_Key() ) ?
            arguments.result.result[ arguments.entity.get_Key() ] :
            arguments.result.result.keyExists( "generated_key" ) ?
            arguments.result.result[ "generated_key" ] :
            arguments.result.result[ "generatedKey" ];
        arguments.entity.assignAttribute(
            arguments.entity.get_Key(),
            generatedKey
        );
    }

}
