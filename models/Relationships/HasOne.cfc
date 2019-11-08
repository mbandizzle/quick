component extends="quick.models.Relationships.HasOneOrMany" {

    public any function getResults() {
        return variables.related.first();
    }

    public array function initRelation(
        required array entities,
        required string relation
    ) {
        for ( var entity in arguments.entities ) {
            entity.assignRelationship(
                arguments.relation,
                javacast( "null", "" )
            );
        }
        return entities;
    }

    public array function match(
        required array entities,
        required array results,
        required string relation
    ) {
        return matchOne( argumentCollection = arguments );
    }

}
