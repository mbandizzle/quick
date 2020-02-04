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

            it( "can constrain a has query using whereHas", function() {
                var users = getInstance( "User" )
                    .whereHas( "posts", function( q ) {
                        q.where( "body", "like", "%different%" );
                    } )
                    .get();
                expect( users ).toBeArray();
                expect( users ).toHaveLength( 1 );
            } );

            it( "can constrain a has query using whereHas and orWhereHas", function() {
                var users = getInstance( "User" )
                    .whereHas( "posts", function( q ) {
                        q.where( "body", "like", "%different%" );
                    } )
                    .orWhereHas( "posts", function( q ) {
                        q.where( "body", "like", "%awesome%" );
                    } )
                    .get();
                expect( users ).toBeArray();
                expect( users ).toHaveLength( 2 );
            } );

            it( "can check nested relationships for existence", function() {
                var users = getInstance( "User" ).has( "posts.comments" ).get();
                expect( users ).toBeArray();
                expect( users ).toHaveLength( 1 );
            } );

            it( "applies count constraints to the final relationship in a nested relationsihp existence check", function() {
                var users = getInstance( "User" )
                    .has( "posts.comments", "=", 2 )
                    .get();
                expect( users ).toBeArray();
                expect( users ).toHaveLength( 1 );

                var users = getInstance( "User" )
                    .has( "posts.comments", ">", 2 )
                    .get();
                expect( users ).toBeArray();
                expect( users ).toBeEmpty();
            } );

            it( "applies whereHas constraints to the final relationship in a nested relationship existence check", function() {
                var users = getInstance( "User" )
                    .whereHas( "posts.comments", function( q ) {
                        q.where( "body", "like", "%great%" );
                    } )
                    .get();

                expect( users ).toBeArray();
                expect( users ).toHaveLength( 1 );
            } );
        } );
    }

}
