component {

    this.name = "quick";
    this.author = "Eric Peterson";
    this.webUrl = "https://github.com/coldbox-modules/quick";
    this.dependencies = [ "qb", "str" ];
    this.cfmapping = "quick";

    function configure() {
        variables.settings = {
            defaultGrammar = "AutoDiscover"
        };

        variables.interceptorSettings = {
            customInterceptionPoints = [
                "quickInstanceReady",
                "quickPreLoad",
                "quickPostLoad",
                "quickPreSave",
                "quickPostSave",
                "quickPreInsert",
                "quickPostInsert",
                "quickPreUpdate",
                "quickPostUpdate",
                "quickPreDelete",
                "quickPostDelete"
            ]
        };

		variables.interceptors = [
			{ class="#variables.moduleMapping#.interceptors.QuickVirtualInheritanceInterceptor" }
        ];

        variables.binder.map( "quick.models.BaseEntity" )
            .to( "#variables.moduleMapping#.models.BaseEntity" );

        variables.binder.getInjector().registerDSL( "quickService", "#variables.moduleMapping#.dsl.QuickServiceDSL" );

        var creatorType = server.keyExists( "lucee" ) ? "LuceeEntityCreator" : "ACFEntityCreator";
        variables.binder.map( "EntityCreator@quick" )
            .to( "#variables.moduleMapping#.extras.#creatorType#" );
    }

    function onLoad() {
        variables.binder.map( "QuickQB@quick" )
            .to( "qb.models.Query.QueryBuilder" )
            .initArg( name = "grammar", dsl = "#variables.settings.defaultGrammar#@qb" )
            .initArg( name = "utils", dsl = "QueryUtils@qb" )
            .initArg( name = "returnFormat", value = "array" );
    }
}
