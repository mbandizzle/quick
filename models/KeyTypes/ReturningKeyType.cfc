component implements="KeyType" {

    /**
     * Called to handle any tasks before inserting into the database.
     * Receives the entity as the only argument.
     */
    public void function preInsert( required any entity ) {
        arguments.entity.retrieveQuery().returning( arguments.entity.get_Key() );
    }

    /**
     * Called to handle any tasks after inserting into the database.
     * Receives the entity and the queryExecute result as arguments.
     */
    public void function postInsert( required any entity, required struct result ) {
        arguments.entity.assignAttribute(
            arguments.entity.get_Key(),
            arguments.result.query[ arguments.entity.get_Key() ]
        );
    }

}
