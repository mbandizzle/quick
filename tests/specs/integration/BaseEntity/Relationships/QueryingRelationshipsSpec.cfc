component extends="tests.resources.ModuleIntegrationSpec" appMapping="/app" {

    function run() {
        describe( "Querying Relationships Spec", function() {
            it( "can find only entities that have one or more related entities", function() {
                var users = getInstance( "User" ).has( "posts" ).get();
                expect( users ).toBeArray();
                expect( users ).toHaveLength( 2 );
            } );

            it( "can constrain the count of the has check", function() {
                var users = getInstance( "User" ).has( "posts", ">=", 2 ).get();
                expect( users ).toBeArray();
                expect( users ).toHaveLength( 1 );

                var users = getInstance( "User" ).has( "posts", "=", 1 ).get();
                expect( users ).toBeArray();
                expect( users ).toHaveLength( 1 );
            } );
        } );
    }

}
