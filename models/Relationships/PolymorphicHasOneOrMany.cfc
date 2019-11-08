component extends="quick.models.Relationships.HasOneOrMany" {

    function init( related, relationName, relationMethodName, parent, type, id, localKey ) {
        variables.morphType = arguments.type;
        variables.morphClass = arguments.parent.get_entityName();
        return super.init(
            arguments.related,
            arguments.relationName,
            arguments.relationMethodName,
            arguments.parent,
            arguments.id,
            arguments.localKey
        );
    }

    function addConstraints() {
        super.addConstraints();
        variables.related.where( variables.morphType, variables.morphClass );
    }

    function addEagerConstraints( entities ) {
        super.addEagerConstraints( arguments.entities );
        variables.related.where( variables.morphType, variables.morphClass );
    }

}
