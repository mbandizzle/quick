component extends="cfcollection.models.Collection" {

    function collect( data ) {
        return new QuickCollection( arguments.data );
    }

    function load( relationName ) {
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

    function getMemento() {
        return this.map( function( entity ) {
            return arguments.entity.$renderData();
        } ).get();
    }

    function $renderData() {
        return variables.getMemento();
    }

    private function eagerLoadRelation( relationName ) {
        var relation = invoke( variables.get( 1 ), arguments.relationName ).resetQuery();
        relation.addEagerConstraints( variables.get() );
        variables.collection = relation.match(
            relation.initRelation( variables.get(), arguments.relationName ),
            relation.getEager(),
            arguments.relationName
        );
    }

}
