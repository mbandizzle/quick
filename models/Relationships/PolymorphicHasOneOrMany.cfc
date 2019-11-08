component extends="quick.models.Relationships.HasOneOrMany" {

    public PolymorphicHasOneOrMany function init(
        required any related,
        required string relationName,
        required string relationMethodName,
        required any parent,
        required string type,
        required string id,
        required string localKey
    ) {
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

    public PolymorphicHasOneOrMany function addConstraints() {
        super.addConstraints();
        variables.related.where(
            variables.morphType,
            variables.morphClass
        );
        return this;
    }

    public PolymorphicHasOneOrMany function addEagerConstraints(
        required array entities
    ) {
        super.addEagerConstraints( arguments.entities );
        variables.related.where(
            variables.morphType,
            variables.morphClass
        );
        return this;
    }

}
