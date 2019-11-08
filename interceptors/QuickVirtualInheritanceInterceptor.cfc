component {

    function afterInstanceInspection( interceptData ) {
        if ( arguments.interceptData.mapping.getObjectMetadata().keyExists( "quick" ) ) {
            arguments.interceptData.mapping.setVirtualInheritance( "quick.models.BaseEntity" );
        }
    }

}
