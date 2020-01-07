component extends="tests.resources.ModuleIntegrationSpec" appMapping="/app" {

    function run() {
        describe( "Querying Relationships Spec", function() {
            it( "can find only entities that have one or more related entities", function() {
                var users = getInstance( "User" ).has( "posts" ).get();
                expect( users ).toBeArray();
                expect( users ).toHaveLength( 1 );
                expect( users[ 1 ].getId() ).toBe( 1 );
            } );
        } );
    }

}
