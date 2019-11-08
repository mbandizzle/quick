component extends="quick.models.Relationships.HasOneOrMany" {

    function getResults() {
        return variables.related.get();
    }

    function initRelation( entities, relation ) {
        for ( var entity in arguments.entities ) {
            entity.assignRelationship( arguments.relation, [] );
        }
        return arguments.entities;
    }

    function match( entities, results, relation ) {
        return matchMany( argumentCollection = arguments );
    }

}
