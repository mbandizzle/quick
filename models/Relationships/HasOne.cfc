component extends="quick.models.Relationships.HasOneOrMany" {

    function getResults() {
        return variables.related.first();
    }

    function initRelation( entities, relation ) {
        for ( var entity in arguments.entities ) {
            entity.assignRelationship( arguments.relation, javacast( "null", "" ) );
        }
        return entities;
    }

    function match( entities, results, relation ) {
        return matchOne( argumentCollection = arguments );
    }

}
