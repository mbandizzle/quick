component extends="cfcollection.models.Collection" {

    public QuickCollection function collect( required any data ) {
        return new QuickCollection( arguments.data );
    }

    public QuickCollection function load( required string relationName ) {
        if ( this.empty() ) {
            return this;
        }

        if ( ! isArray( arguments.relationName ) ) {
            arguments.relationName = [ arguments.relationName ];
        }

        for ( var relation in arguments.relationName ) {
            variables.eagerLoadRelation( relation );
        }

        return this;
    }

    public array function getMemento() {
        return this.map( function( entity ) {
            return arguments.entity.$renderData();
        } ).get();
    }

    public array function $renderData() {
        return variables.getMemento();
    }

    private QuickCollection function eagerLoadRelation( required string relationName ) {
        var relation = invoke( variables.get( 1 ), arguments.relationName ).resetQuery();
        relation.addEagerConstraints( variables.get() );
        variables.collection = relation.match(
            relation.initRelation( variables.get(), arguments.relationName ),
            relation.getEager(),
            arguments.relationName
        );
        return this;
    }

}
