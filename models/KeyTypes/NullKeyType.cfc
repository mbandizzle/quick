component implements="KeyType" {

    /**
     * Called to handle any tasks before inserting into the database.
     * Receives the entity as the only argument.
     */
    public void function preInsert( required any entity ) {
        return;
    }

    /**
     * Called to handle any tasks after inserting into the database.
     * Receives the entity and the queryExecute result as arguments.
     */
    public void function postInsert(
        required any entity,
        required struct result
    ) {
        return;
    }

}
