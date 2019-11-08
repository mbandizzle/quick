component extends="quick.models.Relationships.PolymorphicHasOneOrMany" {

    public any function getResults() {
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
        return matchMany(
            arguments.entities,
            arguments.results,
            arguments.relation
        );
    }

}
