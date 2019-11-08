component extends="quick.models.Relationships.HasOneOrMany" {

    public array function getResults() {
        return variables.related.get();
    }

    public array function initRelation(
        required array entities,
        required string relation
    ) {
        for ( var entity in arguments.entities ) {
            entity.assignRelationship( arguments.relation, [] );
        }
        return arguments.entities;
    }

    public array function match(
        required array entities,
        required array results,
        required string relation
    ) {
        return matchMany( argumentCollection = arguments );
    }

}
