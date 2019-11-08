component accessors="true" {

    /*====================================
    =            Dependencies            =
    ====================================*/
    property name="_builder" inject="provider:QuickQB@quick" persistent="false";
    property name="_wirebox" inject="wirebox" persistent="false";
    property name="_str" inject="provider:Str@str" persistent="false";
    property name="_settings" inject="coldbox:modulesettings:quick" persistent="false";
    property name="_interceptorService" inject="provider:coldbox:interceptorService" persistent="false";
    property name="_entityCreator" inject="provider:EntityCreator@quick" persistent="false";

    /*===========================================
    =            Metadata Properties            =
    ===========================================*/
    property name="_entityName" persistent="false";
    property name="_mapping" persistent="false";
    property name="_fullName" persistent="false";
    property name="_table" persistent="false";
    property name="_queryOptions" persistent="false";
    property name="_readonly" default="false" persistent="false";
    property name="_key" default="id" persistent="false";
    property name="_attributes" persistent="false";
    property name="_meta" persistent="false";
    property name="_nullValues" persistent="false";
    property name="_casts" persistent="false";

    /*=====================================
    =            Instance Data            =
    =====================================*/
    property name="_data" persistent="false";
    property name="_originalAttributes" persistent="false";
    property name="_relationshipsData" persistent="false";
    property name="_relationshipsLoaded" persistent="false";
    property name="_eagerLoad" persistent="false";
    property name="_loaded" persistent="false";
    property name="_globalScopeExclusions" persistent="false";

    public any function init( struct meta = {} ) {
        variables.assignDefaultProperties();
        variables._meta = arguments.meta;
        return this;
    }

    public any function assignDefaultProperties() {
        variables.assignAttributesData( {} );
        variables.assignOriginalAttributes( {} );
        variables._globalScopeExclusions = [];
        param variables._meta = {};
        param variables._data = {};
        param variables._relationshipsData = {};
        param variables._relationshipsLoaded = {};
        param variables._eagerLoad = [];
        param variables._nullValues = {};
        param variables._casts = {};
        param variables._loaded = false;
        return this;
    }

    public void function onDIComplete() {
        variables.metadataInspection();
        variables.fireEvent( "instanceReady", { entity = this } );
    }

    public any function keyType() {
        return variables._wirebox.getInstance( "AutoIncrementingKeyType@quick" );
    }

    public any function retrieveKeyType() {
        if ( isNull( variables.__keyType__ ) ) {
            variables.__keyType__ = variables.keyType();
        }
        return variables.__keyType__;
    }

    /*==================================
    =            Attributes            =
    ==================================*/

    public any function keyValue() {
        variables.guardAgainstNotLoaded( "This instance is not loaded so the `keyValue` cannot be retrieved." );
        return variables.retrieveAttribute( variables._key );
    }

    public struct function retrieveAttributesData(
        boolean aliased = false,
        boolean withoutKey = false,
        boolean withNulls = false
    ) {
        variables._attributes.keyArray().each( function( key ) {
            if ( variables.keyExists( arguments.key ) && ! isReadOnlyAttribute( arguments.key ) ) {
                assignAttribute( arguments.key, variables[ arguments.key ] );
            }
        } );
        var data = {};
        for ( var key in variables._data ) {
            if ( arguments.withoutKey && variables._key == key ) {
                continue;
            }
            if (
                ! variables._data.keyExists( key ) ||
                isNull( variables._data[ key ] ) ||
                ( isNullValue( key, variables._data[ key ] ) && arguments.withNulls )
            ) {
                data[ arguments.aliased ? variables.retrieveAliasForColumn( key ) : key ] = javacast( "null" , "" );
            } else {
                data[ arguments.aliased ? retrieveAliasForColumn( key ) : key ] = variables._data[ key ];
            }
        }
        return data;
    }

    public array function retrieveAttributeNames( boolean columnNames = false ) {
        var names = [];
        for ( var key in variables._attributes ) {
            names.append( arguments.columnNames ? variables._attributes[ key ] : key );
        }
        return names;
    }

    public any function forceClearAttribute(
        required string name,
        boolean setToNull = false
    ) {
        arguments.force = true;
        return variables.clearAttribute( argumentCollection = arguments );
    }

    public any function clearAttribute(
        required string name,
        boolean setToNull = false,
        boolean force = false
    ) {
        if ( arguments.force ) {
            if ( ! variables._attributes.keyExists( variables.retrieveAliasForColumn( arguments.name ) ) ) {
                variables._attributes[ arguments.name ] = arguments.name;
                variables._meta.properties[ arguments.name ] = variables.paramProperty( { "name" = arguments.name } );
                variables._meta.originalMetadata.properties.append( variables._meta.properties[ arguments.name ] );
            }
        }
        if ( arguments.setToNull ) {
            variables._data[ arguments.name ] = javacast( "null", "" );
            variables[ variables.retrieveAliasForColumn( arguments.name ) ] = javacast( "null", "" );
        } else {
            variables._data.delete( arguments.name );
            variables.delete( variables.retrieveAliasForColumn( arguments.name ) );
        }
        return this;
    }

    public any function assignAttributesData( required struct attrs ) {
        if ( isNull( arguments.attrs ) ) {
            variables._loaded = false;
            variables._data = {};
            return this;
        }

        arguments.attrs.each( function( key, value ) {
            if ( variables.keyExists( "set" & variables.retrieveAliasForColumn( arguments.key ) ) ) {
                invoke(
                    this,
                    "set" & variables.retrieveAliasForColumn( arguments.key ),
                    { 1 = arguments.value }
                );
            } else {
                variables._data[ variables.retrieveColumnForAlias( arguments.key ) ] = isNull( arguments.value ) ?
                    javacast( "null", "" ) :
                    arguments.value;
                variables[ variables.retrieveAliasForColumn( arguments.key ) ] = isNull( arguments.value ) ?
                    javacast( "null", "" ) :
                    arguments.value;
            }
        } );

        return this;
    }

    public any function fill(
        required struct attributes,
        boolean ignoreNonExistentAttributes = false
    ) {
        for ( var key in arguments.attributes ) {
            var value = arguments.attributes[ key ];
            var rs = variables.tryRelationshipSetter( "set#key#", { "1" = value } );
			if ( ! isNull( rs ) ) { continue; }
			if( ! arguments.ignoreNonExistentAttributes && ! variables.hasAttribute( key ) ) {
                variables.guardAgainstNonExistentAttribute( key );
			} else if( variables.hasAttribute( key ) ) {
                variables._data[ variables.retrieveColumnForAlias( key ) ] = value;
				invoke( this, "set" & variables.retrieveAliasForColumn( key ), { 1 = value } );
			}
            variables.guardAgainstReadOnlyAttribute( key );
        }
        return this;
    }

    public boolean function hasAttribute( required string name ) {
        return structKeyExists( variables._attributes, variables.retrieveAliasForColumn( arguments.name ) ) ||
            variables._key == arguments.name;
    }

    public boolean function isColumnAlias( required string name ) {
        return structKeyExists( variables._attributes, arguments.name );
    }

    public string function retrieveColumnForAlias( required string name ) {
        return variables._attributes.keyExists( arguments.name ) ?
            variables._attributes[ arguments.name ] :
            arguments.name;
    }

    public string function retrieveAliasForColumn( required string name ) {
        for ( var alias in variables._attributes ) {
            var column = variables._attributes[ alias ];
            if ( column == arguments.name ) {
                arguments.name = alias;
            }
        }
        return arguments.name;
    }

    public struct function transformAttributeAliases( required struct attributes ) {
        return arguments.attributes.reduce( function( acc, key, value ) {
            if ( variables.isColumnAlias( arguments.key ) ) {
                arguments.key = variables.retrieveColumnForAlias( arguments.key );
            }
            arguments.acc[ arguments.key ] = arguments.value;
            return arguments.acc;
        }, {} );
    }

    public any function assignOriginalAttributes( required struct attributes ) {
        variables._originalAttributes = duplicate( arguments.attributes );
        return this;
    }

    public any function markLoaded() {
        variables._loaded = true;
        return this;
    }

    public boolean function isLoaded() {
        return variables._loaded;
    }

    public boolean function isDirty() {
        // TODO: could store hash of incoming attrs and compare hashes.
        // that could get rid of `duplicate` in `assignOriginalAttributes`
        return ! variables.deepEqual(
            variables._originalAttributes,
            variables.retrieveAttributesData()
        );
    }

    public any function retrieveAttribute( required string name, any defaultValue = "" ) {
        if (
            variables.keyExists( variables.retrieveAliasForColumn( arguments.name ) ) &&
            ! variables.isReadOnlyAttribute( arguments.name )
        ) {
            variables.forceAssignAttribute(
                arguments.name,
                variables[ variables.retrieveAliasForColumn( arguments.name ) ]
            );
        }

        if ( ! variables._data.keyExists( variables.retrieveColumnForAlias( arguments.name ) ) ) {
            return variables.castValueForGetter(
                arguments.name,
                arguments.defaultValue
            );
        }

        var data = variables.keyExists( "get" & variables.retrieveAliasForColumn( arguments.name ) ) ?
            invoke( this, "get" & variables.retrieveAliasForColumn( arguments.name ) ) :
            variables._data[ variables.retrieveColumnForAlias( arguments.name ) ];

        return variables.castValueForGetter(
            arguments.name,
            data
        );
    }

    public any function forceAssignAttribute( required string name, required any value ) {
        arguments.force = true;
        return variables.assignAttribute( argumentCollection = arguments );
    }

    public any function assignAttribute(
        required string name,
        required any value,
        boolean force = false
    ) {
        if ( arguments.force ) {
            if ( ! variables._attributes.keyExists( variables.retrieveAliasForColumn( arguments.name ) ) ) {
                variables._attributes[ arguments.name ] = arguments.name;
                variables._meta.properties[ arguments.name ] = variables.paramProperty( { "name" = arguments.name } );
                variables._meta.originalMetadata.properties.append( variables._meta.properties[ arguments.name ] );
            }
        } else {
            variables.guardAgainstNonExistentAttribute( arguments.name );
            variables.guardAgainstReadOnlyAttribute( arguments.name );
        }
        if ( ! isSimpleValue( arguments.value ) ) {
            if ( ! structKeyExists( arguments.value, "keyValue" ) ) {
                throw(
                    type = "QuickNotEntityException",
                    message = "The value assigned to [#arguments.name#] is not a Quick entity.  Perhaps you forgot to add `persistent=""false""` to a new property?",
                    detail = isSimpleValue( arguments.value ) ? arguments.value : getMetadata( arguments.value ).fullname
                );
            }
            arguments.value = variables.castValueForSetter( arguments.name, arguments.value.keyValue() );
        }
        variables._data[ variables.retrieveColumnForAlias( arguments.name ) ] =
            variables.castValueForSetter( arguments.name, arguments.value );
        variables[ variables.retrieveAliasForColumn( arguments.name ) ] =
            variables.castValueForSetter( arguments.name, arguments.value );
        return this;
    }

    public string function qualifyColumn( required string column ) {
        if ( findNoCase( ".", arguments.column ) != 0 ) {
            return arguments.column;
        }
        return variables._table & "." & arguments.column;
    }

    /*=====================================
    =            Query Methods            =
    =====================================*/

    public array function getEntities() {
        variables.applyGlobalScopes();
        return variables.retrieveQuery()
            .get( options = variables._queryOptions )
            .map( function( attrs ) {
                return variables.newEntity()
                    .assignAttributesData( arguments.attrs )
                    .assignOriginalAttributes( arguments.attrs )
                    .markLoaded();
            } );
    }

    public array function all() {
        variables.resetQuery();
        variables.applyGlobalScopes();
        return variables.eagerLoadRelations(
            variables.retrieveQuery()
                .from( variables._table )
                .get( options = variables._queryOptions )
                .map( function( attrs ) {
                    return variables.newEntity()
                        .assignAttributesData( arguments.attrs )
                        .assignOriginalAttributes( arguments.attrs )
                        .markLoaded();
                } )
        );
    }

    public array function get() {
        variables.applyGlobalScopes();
        return variables.eagerLoadRelations(
            variables.getEntities()
        );
    }

    public any function first() {
        variables.applyGlobalScopes();
        var attrs = variables.retrieveQuery().first( options = variables._queryOptions );
        return structIsEmpty( attrs ) ?
            javacast( "null", "" ) :
            variables.newEntity()
                .assignAttributesData( attrs )
                .assignOriginalAttributes( attrs )
                .markLoaded();
    }

    public any function find( required any id ) {
        variables.fireEvent( "preLoad", { id = arguments.id, metadata = variables._meta } );
        variables.applyGlobalScopes();
        var data = variables.retrieveQuery()
            .from( variables._table )
            .find( arguments.id, variables._key, variables._queryOptions );
        if ( structIsEmpty( data ) ) {
            return;
        }
        return variables.tap( variables.loadEntity( data ), function( entity ) {
            variables.fireEvent( "postLoad", { entity = arguments.entity } );
        } );
    }

    private any function loadEntity( required struct data ) {
        return variables.newEntity()
            .assignAttributesData( arguments.data )
            .assignOriginalAttributes( arguments.data )
            .markLoaded();
    }

    public any function findOrFail( required any id ) {
        var entity = variables.find( arguments.id );
        if ( isNull( entity ) ) {
            throw(
                type = "EntityNotFound",
                message = "No [#variables._entityName#] found with id [#arguments.id#]"
            );
        }
        return entity;
    }

    public any function firstOrFail() {
        variables.applyGlobalScopes();
        var attrs = variables.retrieveQuery().first( options = variables._queryOptions );
        if ( structIsEmpty( attrs ) ) {
            throw(
                type = "EntityNotFound",
                message = "No [#variables._entityName#] found with constraints [#serializeJSON( variables.retrieveQuery().getBindings() )#]"
            );
        }
        return variables.newEntity()
            .assignAttributesData( attrs )
            .assignOriginalAttributes( attrs )
            .markLoaded();
    }

    public any function newEntity( string name ) {
        if ( isNull( arguments.name ) ) {
            return variables._entityCreator.new( this );
        }
        return variables._wirebox.getInstance( arguments.name );
    }

    public any function reset() {
        variables.assignAttributesData( {} );
        variables.assignOriginalAttributes( {} );
        variables._data = {};
        variables._relationshipsData = {};
        variables._relationshipsLoaded = {};
        variables._eagerLoad = [];
        variables._loaded = false;
        return this;
    }

    public any function fresh() {
        return variables.resetQuery().find( variables.keyValue() );
    }

    public any function refresh() {
        variables._relationshipsData = {};
        variables._relationshipsLoaded = {};
        variables.assignAttributesData(
            variables.newQuery()
                .from( variables._table )
                .find( variables.keyValue(), variables._key, variables._queryOptions )
        );
        return this;
    }

    /*===========================================
    =            Persistence Methods            =
    ===========================================*/

    public any function save() {
        variables.guardNoAttributes();
        variables.guardReadOnly();
        variables.fireEvent( "preSave", { entity = this } );
        if ( variables._loaded ) {
            variables.fireEvent( "preUpdate", { entity = this } );
            variables.newQuery()
                .where( variables._key, variables.keyValue() )
                .update(
                    variables.retrieveAttributesData( withoutKey = true )
                        .filter( canUpdateAttribute )
                        .map( function( key, value, attributes ) {
                            if ( isNull( arguments.value ) || variables.isNullValue( arguments.key, arguments.value ) ) {
                                return { value = "", nulls = true, null = true };
                            }
                            if ( attributeHasSqlType( arguments.key ) ) {
                                return { value = arguments.value, cfsqltype = variables.getSqlTypeForAttribute( arguments.key ) };
                            }
                            return arguments.value;
                        } ),
                    variables._queryOptions
                );
            variables.assignOriginalAttributes( variables.retrieveAttributesData() );
            variables.markLoaded();
            variables.fireEvent( "postUpdate", { entity = this } );
        }
        else {
            variables.resetQuery();
            variables.retrieveKeyType().preInsert( this );
            variables.fireEvent( "preInsert", { entity = this, attributes = variables.retrieveAttributesData() } );
            var attrs = variables.retrieveAttributesData()
                .filter( canInsertAttribute )
                .map( function( key, value, attributes ) {
                    if ( isNull( arguments.value ) || variables.isNullValue( arguments.key, arguments.value ) ) {
                        return { value = "", nulls = true, null = true };
                    }
                    if ( variables.attributeHasSqlType( arguments.key ) ) {
                        return { value = arguments.value, cfsqltype = variables.getSqlTypeForAttribute( arguments.key ) };
                    }
                    return arguments.value;
                } );
            variables.guardEmptyAttributeData( attrs );
            var result = variables.retrieveQuery().insert(
                attrs,
                variables._queryOptions
            );
            variables.retrieveKeyType().postInsert( this, result );
            variables.assignOriginalAttributes( variables.retrieveAttributesData() );
            variables.markLoaded();
            variables.fireEvent( "postInsert", { entity = this } );
        }
        variables.fireEvent( "postSave", { entity = this } );

        return this;
    }

    public any function delete() {
        variables.guardReadOnly();
        variables.fireEvent( "preDelete", { entity = this } );
        variables.guardAgainstNotLoaded( "This instance is not loaded so it cannot be deleted.  Did you maybe mean to use `deleteAll`?" );
        variables.newQuery().delete( variables.keyValue(), variables._key, variables._queryOptions );
        variables._loaded = false;
        variables.fireEvent( "postDelete", { entity = this } );
        return this;
    }

    public any function update(
        struct attributes = {},
        boolean ignoreNonExistentAttributes = false
    ) {
        variables.guardAgainstNotLoaded( "This instance is not loaded so it cannot be updated.  Did you maybe mean to use `updateAll`, `insert`, or `save`?" );
        variables.fill( arguments.attributes, arguments.ignoreNonExistentAttributes );
        return variables.save();
    }

    public any function create(
        struct attributes = {},
        boolean ignoreNonExistentAttributes = false
    ) {
        return variables.newEntity()
            .fill( arguments.attributes, arguments.ignoreNonExistentAttributes )
            .save();
    }

    public any function updateAll(
        struct attributes = {},
        boolean force = false
    ) {
        if ( ! arguments.force ) {
            variables.guardReadOnly();
            variables.guardAgainstReadOnlyAttributes( arguments.attributes );
        }
        return variables.retrieveQuery()
            .update( arguments.attributes, variables._queryOptions );
    }

    public any function deleteAll( array ids = [] ) {
        variables.guardReadOnly();
        if ( ! arrayIsEmpty( arguments.ids ) ) {
            variables.retrieveQuery().whereIn( variables._key, arguments.ids );
        }
        return variables.retrieveQuery().delete( options = variables._queryOptions );
    }

    /*=====================================
    =            Relationships            =
    =====================================*/

    public boolean function hasRelationship( required string name ) {
        return variables._meta.functionNames.contains( lcase( arguments.name ) );
    }

    public any function loadRelationship( required string name ) {
        arguments.name = isArray( arguments.name ) ? arguments.name : [ arguments.name ];
        arguments.name.each( function( n ) {
            var relationship = invoke( this, arguments.n );
            relationship.setRelationMethodName( arguments.n );
            variables.assignRelationship( arguments.n, relationship.get() );
        } );
        return this;
    }

    public boolean function isRelationshipLoaded( required string name ) {
        return structKeyExists( variables._relationshipsLoaded, arguments.name );
    }

    public any function retrieveRelationship( required string name ) {
        return variables._relationshipsData.keyExists( arguments.name ) ?
            variables._relationshipsData[ arguments.name ] :
            javacast( "null", "" );
    }

    public any function assignRelationship(
        required string name,
        any value
    ) {
        if ( ! isNull( arguments.value ) ) {
            variables._relationshipsData[ arguments.name ] = arguments.value;
        }
        variables._relationshipsLoaded[ arguments.name ] = true;
        return this;
    }

    public any function clearRelationships() {
        variables._relationshipsData = {};
        return this;
    }

    public any function clearRelationship( required string name ) {
        variables._relationshipsData.delete( arguments.name );
        return this;
    }

    private any function belongsTo(
        required string relationName,
        string foreignKey,
        string ownerKey,
        string relationMethodName
    ) {
        var related = variables._wirebox.getInstance( arguments.relationName );

        if ( isNull( arguments.foreignKey ) ) {
            arguments.foreignKey = related.get_EntityName() & related.get_Key();
        }
        if ( isNull( arguments.ownerKey ) ) {
            arguments.ownerKey = related.get_Key();
        }
        if ( isNull( arguments.relationMethodName ) ) {
            arguments.relationMethodName = lcase( callStackGet()[ 2 ][ "Function" ] );
        }
        return variables._wirebox.getInstance( name = "BelongsTo@quick", initArguments = {
            related = related,
            relationName = arguments.relationName,
            relationMethodName = arguments.relationMethodName,
            parent = this,
            foreignKey = arguments.foreignKey,
            ownerKey = arguments.ownerKey
        } );
    }

    private any function hasOne(
        required string relationName,
        string foreignKey,
        string localKey,
        string relationMethodName
    ) {
        var related = variables._wirebox.getInstance( arguments.relationName );
        if ( isNull( arguments.foreignKey ) ) {
            arguments.foreignKey = variables._entityName & variables._key;
        }
        if ( isNull( arguments.localKey ) ) {
            arguments.localKey = variables._key;
        }
        if ( isNull( arguments.relationMethodName ) ) {
            arguments.relationMethodName = lcase( callStackGet()[ 2 ][ "Function" ] );
        }
        return variables._wirebox.getInstance( name = "HasOne@quick", initArguments = {
            related = related,
            relationName = arguments.relationName,
            relationMethodName = arguments.relationMethodName,
            parent = this,
            foreignKey = arguments.foreignKey,
            localKey = arguments.localKey
        } );
    }

    private any function hasMany(
        required string relationName,
        string foreignKey,
        string localKey,
        string relationMethodName
    ) {
        var related = variables._wirebox.getInstance( arguments.relationName );
        if ( isNull( arguments.foreignKey ) ) {
            arguments.foreignKey = variables._entityName & variables._key;
        }
        if ( isNull( arguments.localKey ) ) {
            arguments.localKey = variables._key;
        }
        if ( isNull( arguments.relationMethodName ) ) {
            arguments.relationMethodName = lcase( callStackGet()[ 2 ][ "Function" ] );
        }
        return variables._wirebox.getInstance( name = "HasMany@quick", initArguments = {
            related = related,
            relationName = arguments.relationName,
            relationMethodName = arguments.relationMethodName,
            parent = this,
            foreignKey = arguments.foreignKey,
            localKey = arguments.localKey
        } );
    }

    private any function belongsToMany(
        required string relationName,
        string table,
        string foreignPivotKey,
        string relatedPivotKey,
        string parentKey,
        string relatedKey,
        string relationMethodName
    ) {
        var related = variables._wirebox.getInstance( arguments.relationName );
        if ( isNull( arguments.table ) ) {
            if ( compareNoCase( related.get_Table(), variables._table ) < 0 ) {
                arguments.table = lcase( "#related.get_Table()#_#variables._table#" );
            }
            else {
                arguments.table = lcase( "#variables._table#_#related.get_Table()#" );
            }
        }
        if ( isNull( arguments.foreignPivotKey ) ) {
            arguments.foreignPivotKey = variables._entityName & variables._key;
        }
        if ( isNull( arguments.relatedPivotKey ) ) {
            arguments.relatedPivotKey = related.get_entityName() & related.get_key();
        }
        if ( isNull( arguments.relationMethodName ) ) {
            arguments.relationMethodName = lcase( callStackGet()[ 2 ][ "Function" ] );
        }
        if ( isNull( arguments.parentKey ) ) {
            arguments.parentKey = variables._key;
        }
        if ( isNull( arguments.relatedKey ) ) {
            arguments.relatedKey = related.get_key();
        }
        return variables._wirebox.getInstance( name = "BelongsToMany@quick", initArguments = {
            related = related,
            relationName = arguments.relationName,
            relationMethodName = arguments.relationMethodName,
            parent = this,
            table = arguments.table,
            foreignPivotKey = arguments.foreignPivotKey,
            relatedPivotKey = arguments.relatedPivotKey,
            parentKey = arguments.parentKey,
            relatedKey = arguments.relatedKey
        } );
    }

    private any function hasManyThrough(
        required string relationName,
        string intermediateName,
        string firstKey,
        string secondKey,
        string localKey,
        string secondLocalKey,
        string relationMethodName
    ) {
        var related = variables._wirebox.getInstance( arguments.relationName );
        var intermediate = variables._wirebox.getInstance( arguments.intermediateName );
        if ( isNull( arguments.firstKey ) ) {
            arguments.firstKey = intermediate.get_EntityName() & intermediate.get_Key();
        }
        if ( isNull( arguments.firstKey ) ) {
            arguments.firstKey = variables._entityName & variables._key;
        }
        if ( isNull( arguments.secondKey ) ) {
            arguments.secondKey = intermediate.get_entityName() & intermediate.get_key();
        }
        if ( isNull( arguments.localKey ) ) {
            arguments.localKey = variables._key;
        }
        if ( isNull( arguments.secondLocalKey ) ) {
            arguments.secondLocalKey = intermediate.get_key();
        }
        if ( isNull( arguments.relationMethodName ) ) {
            arguments.relationMethodName = lcase( callStackGet()[ 2 ][ "Function" ] );
        }
        return variables._wirebox.getInstance( name = "HasManyThrough@quick", initArguments = {
            related = related,
            relationName = arguments.relationName,
            relationMethodName = arguments.relationMethodName,
            parent = this,
            intermediate = intermediate,
            firstKey = arguments.firstKey,
            secondKey = arguments.secondKey,
            localKey = arguments.localKey,
            secondLocalKey = arguments.secondLocalKey
        } );
    }

    private any function polymorphicHasMany(
        required string relationName,
        required string name,
        string type,
        string id,
        string localKey,
        string relationMethodName
    ) {
        var related = variables._wirebox.getInstance( arguments.relationName );

        if ( isNull( arguments.type ) ) {
            arguments.type = arguments.name & "_type";
        }
        if ( isNull( arguments.id ) ) {
            arguments.id = arguments.name & "_id";
        }
        var table = related.get_table();
        if ( isNull( arguments.localKey ) ) {
            arguments.localKey = variables._key;
        }
        if ( isNull( arguments.relationMethodName ) ) {
            arguments.relationMethodName = lcase( callStackGet()[ 2 ][ "Function" ] );
        }

        return variables._wirebox.getInstance( name = "PolymorphicHasMany@quick", initArguments = {
            related = related,
            relationName = arguments.relationName,
            relationMethodName = arguments.relationMethodName,
            parent = this,
            type = arguments.type,
            id = arguments.id,
            localKey = arguments.localKey
        } );
    }

    private any function polymorphicBelongsTo(
        string name,
        string type,
        string id,
        string ownerKey
    ) {
        if ( isNull( arguments.name ) ) {
            arguments.name = lcase( callStackGet()[ 2 ][ "Function" ] );
        }
        if ( isNull( arguments.type ) ) {
            arguments.type = arguments.name & "_type";
        }
        if ( isNull( arguments.id ) ) {
            arguments.id = arguments.name & "_id";
        }
        var relationName = variables.retrieveAttribute( arguments.type, "" );
        if ( relationName == "" ) {
            return variables._wirebox.getInstance( name = "PolymorphicBelongsTo@quick", initArguments = {
                related = this.set_EagerLoad( [] ).resetQuery(),
                relationName = relationName,
                relationMethodName = arguments.name,
                parent = this,
                foreignKey = arguments.id,
                ownerKey = "",
                type = arguments.type
            } );
        }
        var related = variables._wirebox.getInstance( relationName );
        if ( isNull( arguments.ownerKey ) ) {
            arguments.ownerKey = related.get_key();
        }
        return variables._wirebox.getInstance( name = "PolymorphicBelongsTo@quick", initArguments = {
            related = related,
            relationName = relationName,
            relationMethodName = arguments.name,
            parent = this,
            foreignKey = arguments.id,
            ownerKey = arguments.ownerKey,
            type = arguments.type
        } );
    }

    public any function with( required any relationName ) {
        if ( isSimpleValue( arguments.relationName ) && arguments.relationName == "" ) {
            return this;
        }
        arguments.relationName = isArray( arguments.relationName ) ? arguments.relationName : [ arguments.relationName ];
        arrayAppend( variables._eagerLoad, arguments.relationName, true );
        return this;
    }

    public array function eagerLoadRelations( required array entities ) {
        if ( arrayIsEmpty( arguments.entities ) || arrayIsEmpty( variables._eagerLoad ) ) {
            return entities;
        }

        for ( var relationName in variables._eagerLoad ) {
            arguments.entities = variables.eagerLoadRelation( relationName, arguments.entities );
        }

        return arguments.entities;
    }

    private array function eagerLoadRelation(
        required any relationName,
        required array entities
    ) {
        var callback = function() {};
        if ( ! isSimpleValue( arguments.relationName ) ) {
            if ( ! isStruct( arguments.relationName ) ) {
                throw(
                    type = "QuickInvalidEagerLoadParameter",
                    message = "Only strings or structs are supported eager load parameters.  You passed [#serializeJSON( arguments.relationName )#"
                );
            }
            for ( var key in arguments.relationName ) {
                callback = arguments.relationName[ key ];
                arguments.relationName = key;
                break;
            }
        }
        var currentRelationship = listFirst( arguments.relationName, "." );
        var relation = invoke( this, currentRelationship ).resetQuery();
        callback( relation );
        relation.addEagerConstraints( arguments.entities );
        relation.with( listRest( arguments.relationName, "." ) );
        return relation.match(
            relation.initRelation( arguments.entities, currentRelationship ),
            relation.getEager(),
            currentRelationship
        );
    }

    /*=======================================
    =            QB Utilities            =
    =======================================*/

    public any function resetQuery() {
        variables.newQuery();
        return this;
    }

    public QueryBuilder function newQuery() {
        if ( variables._meta.originalMetadata.keyExists( "grammar" ) ) {
            variables._builder.setGrammar(
                // TODO: Change to use the mapping as itself when upgrading to qb@7
                variables._wirebox.getInstance( variables._meta.originalMetadata.grammar & "@qb" )
            );
        }
        variables.query = variables._builder.newQuery()
            .setReturnFormat( "array" )
            .setColumnFormatter( function( column ) {
                return variables.retrieveColumnForAlias( arguments.column );
            } )
            .from( variables._table );

        return variables.query;
    }

    public QueryBuilder function retrieveQuery() {
        if ( ! structKeyExists( variables, "query" ) ) {
            variables.query = variables.newQuery();
        }
        return variables.query;
    }

    public any function addSubselect( required string name, required any subselect ) {
        if ( ! variables._attributes.keyExists( variables.retrieveAliasForColumn( arguments.name ) ) ) {
            variables._attributes[ arguments.name ] = arguments.name;
            variables._meta.properties[ arguments.name ] = variables.paramProperty( {
                "name" = arguments.name,
                "update" = false,
                "insert" = false
            } );
            variables._meta.originalMetadata.properties.append( variables._meta.properties[ arguments.name ] );
        }

        if (
            variables.retrieveQuery().getColumns().isEmpty() ||
            (
                variables.retrieveQuery().getColumns().len() == 1 &&
                isSimpleValue( variables.retrieveQuery().getColumns()[ 1 ] ) &&
                variables.retrieveQuery().getColumns()[ 1 ] == "*"
            )
        ) {
            variables.retrieveQuery().select( variables.retrieveQuery().getFrom() & ".*" );
        }

        var subselectQuery = arguments.subselect;
        if ( isClosure( subselectQuery ) ) {
            subselectQuery = variables.retrieveQuery().newQuery();
            subselectQuery = arguments.subselect( subselectQuery );
        }

        variables.retrieveQuery().subselect( name, subselectQuery.retrieveQuery().limit( 1 ) );
        return this;
    }

    /*=====================================
    =            Magic Methods            =
    =====================================*/

    public any function onMissingMethod(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        var columnValue = variables.tryColumnName( arguments.missingMethodName, arguments.missingMethodArguments );
        if ( ! isNull( columnValue ) ) { return columnValue; }
        var q = variables.tryScopes( arguments.missingMethodName, arguments.missingMethodArguments );
        if ( ! isNull( q ) ) {
            if ( isStruct( q ) && structKeyExists( q, "retrieveQuery" ) ) {
                variables.query = q.retrieveQuery();
                return this;
            }
            return q;
        }
        var rg = variables.tryRelationshipGetter( arguments.missingMethodName, arguments.missingMethodArguments );
        if ( ! isNull( rg ) ) { return rg; }
        var rs = variables.tryRelationshipSetter( arguments.missingMethodName, arguments.missingMethodArguments );
        if ( ! isNull( rs ) ) { return rs; }
        if ( variables.relationshipIsNull( arguments.missingMethodName ) ) {
            return javacast( "null", "" );
        }
        return variables.forwardToQB( arguments.missingMethodName, arguments.missingMethodArguments );
    }

    private any function tryColumnName(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        var getColumnValue = variables.tryColumnGetters( arguments.missingMethodName );
        if ( ! isNull( getColumnValue ) ) { return getColumnValue; }
        var setColumnValue = variables.tryColumnSetters( arguments.missingMethodName, arguments.missingMethodArguments );
        if ( ! isNull( setColumnValue ) ) { return this; }
        return;
    }

    private any function tryColumnGetters( required string missingMethodName ) {
        if ( ! variables._str.startsWith( arguments.missingMethodName, "get" ) ) {
            return;
        }

        var columnName = variables._str.slice( arguments.missingMethodName, 4 );

        if ( variables.hasAttribute( columnName ) ) {
            return variables.retrieveAttribute( variables.retrieveColumnForAlias( columnName ) );
        }

        return;
    }

    private any function tryColumnSetters(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        if ( ! variables._str.startsWith( arguments.missingMethodName, "set" ) ) {
            return;
        }

        var columnName = variables._str.slice( arguments.missingMethodName, 4 );
        if ( ! variables.hasAttribute( columnName ) ) {
            return;
        }
        variables.assignAttribute( columnName, arguments.missingMethodArguments[ 1 ] );
        return arguments.missingMethodArguments[ 1 ];
    }

    private any function tryRelationshipGetter(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        if ( ! variables._str.startsWith( arguments.missingMethodName, "get" ) ) {
            return;
        }

        var relationshipName = variables._str.slice( arguments.missingMethodName, 4 );

        if ( ! variables.hasRelationship( relationshipName ) ) {
            return;
        }

        if ( ! variables.isRelationshipLoaded( relationshipName ) ) {
            var relationship = invoke( this, relationshipName, arguments.missingMethodArguments );
            relationship.setRelationMethodName( relationshipName );
            variables.assignRelationship( relationshipName, relationship.get() );
        }

        return variables.retrieveRelationship( relationshipName );
    }

    private any function tryRelationshipSetter(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        if ( ! variables._str.startsWith( arguments.missingMethodName, "set" ) ) {
            return;
        }

        var relationshipName = variables._str.slice( arguments.missingMethodName, 4 );

        if ( ! variables.hasRelationship( relationshipName ) ) {
            return;
        }

        var relationship = invoke( this, relationshipName );

        return relationship.applySetter( argumentCollection = arguments.missingMethodArguments );
    }

    private boolean function relationshipIsNull( required string name ) {
        if ( ! variables._str.startsWith( arguments.name, "get" ) ) {
            return false;
        }
        return variables._relationshipsLoaded.keyExists( variables._str.slice( arguments.name, 4 ) );
    }

    private any function tryScopes(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        if ( structKeyExists( variables, "scope#arguments.missingMethodName#" ) ) {
            if ( arrayContains( variables._globalScopeExclusions, lcase( arguments.missingMethodName ) ) ) {
                return this;
            }
            var scopeArgs = { "1" = this };
            // this is to allow default arguments to be set for scopes
            if ( ! structIsEmpty( arguments.missingMethodArguments ) ) {
                for ( var i = 1; i <= structCount( arguments.missingMethodArguments ); i++ ) {
                    scopeArgs[ i + 1 ] = arguments.missingMethodArguments[ i ];
                }
            }
            var result = invoke( this, "scope#arguments.missingMethodName#", scopeArgs );
            return isNull( result ) ? this : result;
        }
        return;
    }

    private any function applyGlobalScopes() {
        return this;
    }

    public any function withoutGlobalScope( required any name ) {
        arguments.name = isArray( arguments.name ) ? arguments.name : [ arguments.name ];
        arguments.name.each( function( n ) {
            variables._globalScopeExclusions.append( lcase( arguments.n ) );
        } );
        return this;
    }

    private any function forwardToQB(
        required string missingMethodName,
        required struct missingMethodArguments
    ) {
        var result = invoke(
            variables.retrieveQuery(),
            arguments.missingMethodName,
            arguments.missingMethodArguments
        );
        if ( isSimpleValue( result ) ) {
            return result;
        }
        return this;
    }

    public struct function getMemento() {
        var data = variables._attributes.keyArray().reduce( function( acc, key ) {
            arguments.acc[ arguments.key ] = variables.retrieveAttribute( arguments.key );
            return arguments.acc;
        }, {} );
        var loadedRelations = variables._relationshipsData.reduce( function( acc, relationshipName, relation ) {
            if ( isArray( arguments.relation ) ) {
                var mementos = arguments.relation.map( function( r ) {
                    return arguments.r.getMemento();
                } );
                // ACF 11 doesn't let use directly assign the result of map
                // to a dynamic struct key. ¯\_(ツ)_/¯
                arguments.acc[ arguments.relationshipName ] = mementos;
            } else {
                arguments.acc[ arguments.relationshipName ] = arguments.relation.getMemento();
            }
            return arguments.acc;
        }, {} );
        structAppend( data, loadedRelations );
        return data;
    }

    public struct function $renderdata() {
        return variables.getMemento();
    }

    /*=======================================
    =            Other Utilities            =
    =======================================*/

    private any function tap( required any value, required any callback ) {
        arguments.callback( arguments.value );
        return arguments.value;
    }

    private any function metadataInspection() {
        if ( ! isStruct( variables._meta ) || structIsEmpty( variables._meta ) ) {
            var util = createObject( "component", "coldbox.system.core.util.Util" );
            variables._meta = {
                "originalMetadata" = util.getInheritedMetadata( this )
            };
        }
        param variables._key = "id";
        param variables._meta.fullName = variables._meta.originalMetadata.fullname;
        variables._fullName = variables._meta.fullName;
        param variables._meta.originalMetadata.mapping = listLast( variables._meta.originalMetadata.fullname, "." );
        param variables._meta.mapping = variables._meta.originalMetadata.mapping;
        variables._mapping = variables._meta.mapping;
        param variables._meta.originalMetadata.entityName = listLast( variables._meta.originalMetadata.name, "." );
        param variables._meta.entityName = variables._meta.originalMetadata.entityName;
        variables._entityName = variables._meta.entityName;
        param variables._meta.originalMetadata.table = variables._str.plural( variables._str.snake( variables._entityName ) );
        param variables._meta.table = variables._meta.originalMetadata.table;
        variables._table = variables._meta.table;
        param variables._queryOptions = {};
        if ( variables._queryOptions.isEmpty() && variables._meta.originalMetadata.keyExists( "datasource" ) ) {
            variables._queryOptions = { datasource = variables._meta.originalMetadata.datasource };
        }
        param variables._meta.originalMetadata.readonly = false;
        param variables._meta.readonly = variables._meta.originalMetadata.readonly;
        variables._readonly = variables._meta.readonly;
        param variables._meta.originalMetadata.functions = [];
        param variables._meta.functionNames = variables.generateFunctionNameList( variables._meta.originalMetadata.functions );
        param variables._meta.originalMetadata.properties = [];
        param variables._meta.properties = variables.generateProperties( variables._meta.originalMetadata.properties );
        if ( ! variables._meta.properties.keyExists( variables._key ) ) {
            var keyProp = variables.paramProperty( { "name" = variables._key } );
            variables._meta.properties[ keyProp.name ] = keyProp;
        }
        variables.assignAttributesFromProperties( variables._meta.properties );
        return this;
    }

    private array function generateFunctionNameList( required array functions ) {
        return arguments.functions.map( function( func ) {
            return lcase( arguments.func.name );
        } );
    }

    private struct function generateProperties( required array properties ) {
        return arguments.properties.reduce( function( acc, prop ) {
            var newProp = variables.paramProperty( arguments.prop );
            if ( ! newProp.persistent ) {
                return arguments.acc;
            }
            arguments.acc[ newProp.name ] = newProp;
            return arguments.acc;
        }, {} );
    }

    private struct function paramProperty( required struct prop ) {
        param arguments.prop.column = arguments.prop.name;
        param arguments.prop.persistent = true;
        param arguments.prop.nullValue = "";
        param arguments.prop.convertToNull = true;
        param arguments.prop.casts = "";
        param arguments.prop.readOnly = false;
        param arguments.prop.sqltype = "";
        param arguments.prop.insert = true;
        param arguments.prop.update = true;
        return arguments.prop;
    }

    private any function assignAttributesFromProperties( required struct properties ) {
        for ( var alias in arguments.properties ) {
            var options = arguments.properties[ alias ];
            variables._attributes[ alias ] = options.column;
            if ( options.convertToNull ) {
                variables._nullValues[ alias ] = options.nullValue;
            }
            if ( options.casts != "" ) {
                variables._casts[ alias ] = options.casts;
            }
        }
        return this;
    }

    private boolean function deepEqual( required expected, required actual ) {
        // Numerics
        if (
            isNumeric( arguments.actual ) &&
            isNumeric( arguments.expected ) &&
            compare( toString( arguments.actual ), toString( arguments.expected ) ) == 0
        ) {
            return true;
        }

        // Other Simple values
        if (
            isSimpleValue( arguments.actual ) &&
            isSimpleValue( arguments.expected ) &&
            compare( arguments.actual, arguments.expected ) == 0
        ) {
            return true;
        }

        // Queries
        if ( isQuery( arguments.actual ) && isQuery( arguments.expected ) ) {
            // Check number of records
            if ( arguments.actual.recordCount != arguments.expected.recordCount ) {
                return false;
            }

            // Get both column lists and sort them the same
            var actualColumnList = listSort( arguments.actual.columnList, "textNoCase" );
            var expectedColumnList = listSort( arguments.expected.columnList, "textNoCase" );

            // Check column lists
            if ( actualColumnList != expectedColumnList ) {
                return false;
            }

            for ( var i = 1; i <= arguments.actual.recordCount; i++ ) {
                for ( var column in listToArray( actualColumnList ) ) {
                    if ( arguments.actual[ column ][ i ] != arguments.expected[ column ][ i ] ) {
                        return false;
                    }
                }
            }

            return true;
        }

        // UDFs
        if (
            isCustomFunction( arguments.actual ) &&
            isCustomFunction( arguments.expected ) &&
            compare( arguments.actual.toString(), arguments.expected.toString() ) == 0
        ) {
            return true;
        }

        // XML
        if (
            IsXmlDoc( arguments.actual ) &&
            IsXmlDoc( arguments.expected ) &&
            compare( toString( arguments.actual ), toString( arguments.expected ) ) == 0
        ) {
            return true;
        }

        // Arrays
        if ( isArray( arguments.actual ) && isArray( arguments.expected ) ) {
            if ( arrayLen( arguments.actual ) neq arrayLen( arguments.expected ) ) {
                return false;
            }

            for ( var i = 1; i <= arrayLen( arguments.actual ); i++ ) {
                if ( arrayIsDefined( arguments.actual, i ) && arrayIsDefined( arguments.expected, i ) ) {
                    // check for both nulls
                    if ( isNull( arguments.actual[ i ] ) && isNull( arguments.expected[ i ] ) ) {
                        continue;
                    }
                    // check if one is null mismatch
                    if ( isNull( arguments.actual[ i ] ) || isNull( arguments.expected[ i ] ) ) {
                        return false;
                    }
                    // And make sure they match
                    if ( ! deepEqual( arguments.actual[ i ], arguments.expected[ i ] ) ) {
                        return false;
                    }
                    continue;
                }
                // check if both not defined, then continue to next element
                if ( ! arrayIsDefined( arguments.actual, i ) && ! arrayIsDefined( arguments.expected, i ) ) {
                    continue;
                } else {
                    return false;
                }
            }

            return true;
        }

        // Structs / Object
        if ( isStruct( arguments.actual ) && isStruct( arguments.expected ) ) {

            var actualKeys = listSort( structKeyList( arguments.actual ), "textNoCase" );
            var expectedKeys = listSort( structKeyList( arguments.expected ), "textNoCase" );

            if ( actualKeys != expectedKeys ) {
                return false;
            }

            // Loop over each key
            for ( var key in arguments.actual ) {
                // check for both nulls
                if ( isNull( arguments.actual[ key ] ) && isNull( arguments.expected[ key ] ) ) {
                    continue;
                }
                // check if one is null mismatch
                if ( isNull( arguments.actual[ key ] ) || isNull( arguments.expected[ key ] ) ) {
                    return false;
                }
                // And make sure they match when actual values exist
                if ( ! deepEqual( arguments.actual[ key ], arguments.expected[ key ] ) ) {
                    return false;
                }
            }

            return true;
        }

        return false;
    }

    /*=================================
    =            Read Only            =
    =================================*/

    private void function guardReadOnly() {
        if ( variables.isReadOnly() ) {
            throw(
                type = "QuickReadOnlyException",
                message = "[#variables._entityName#] is marked as a read-only entity."
            );
        }
    }

    private boolean function isReadOnly() {
        return variables._readonly;
    }

    private void function guardAgainstReadOnlyAttributes( required struct attributes ) {
        for ( var name in arguments.attributes ) {
            variables.guardAgainstReadOnlyAttribute( name );
        }
    }

    private void function guardAgainstNonExistentAttribute( required string name ) {
        if ( ! variables.hasAttribute( arguments.name ) ) {
            throw(
                type = "AttributeNotFound",
                message = "The [#arguments.name#] attribute was not found on the [#variables._entityName#] entity"
            );
        }
    }

    private any function guardAgainstReadOnlyAttribute( required string name ) {
        if ( variables.isReadOnlyAttribute( arguments.name ) ) {
            throw(
                type = "QuickReadOnlyException",
                message = "[#arguments.name#] is a read-only property on [#variables._entityName#]"
            );
        }
    }

    private boolean function isReadOnlyAttribute( required string name ) {
        var alias = variables.retrieveAliasForColumn( arguments.name );
        return variables._meta.properties.keyExists( alias ) &&
            variables._meta.properties[ alias ].readOnly;
    }

    private void function guardNoAttributes() {
        if ( variables.retrieveAttributeNames().isEmpty() ) {
            throw(
                type = "QuickNoAttributesException",
                message = "[#variables._entityName#] does not have any attributes specified."
            );
        }
    }

    private void function guardEmptyAttributeData( required struct attrs ) {
        if ( arguments.attrs.isEmpty() ) {
            throw(
                type = "QuickNoAttributesDataException",
                message = "[#variables._entityName#] does not have any attributes data for insert."
            );
        }
    }

    private void function guardAgainstNotLoaded( required string errorMessage ) {
        if ( ! variables.isLoaded() ) {
            throw(
                type = "QuickEntityNotLoaded",
                message = arguments.errorMessage
            );
        }
    }

    /*==============================
    =            Events          =
    ==============================*/

    private any function fireEvent( required string eventName, required any eventData ) {
        arguments.eventData.entityName = variables._entityName;
        if ( variables.eventMethodExists( arguments.eventName ) ) {
            invoke( this, arguments.eventName, { eventData = arguments.eventData } );
        }
        if ( ! isNull( variables._interceptorService ) ) {
            variables._interceptorService.processState( "quick" & arguments.eventName, arguments.eventData );
        }
        return this;
    }

    private boolean function eventMethodExists( required string eventName ) {
        return variables.keyExists( arguments.eventName );
    }

    private boolean function attributeHasSqlType( required string name ) {
        var alias = variables.retrieveAliasForColumn( arguments.name );
        return variables._meta.properties.keyExists( alias ) &&
            variables._meta.properties[ alias ].sqltype != "";
    }

    private string function getSqlTypeForAttribute( required string name ) {
        var alias = variables.retrieveAliasForColumn( arguments.name );
        return variables._meta.properties[ alias ].sqltype;
    }

    public boolean function isNullAttribute( required string key ) {
        return variables.isNullValue( key, variables.retrieveAttribute( key ) );
    }

    private boolean function isNullValue( required string key, any value ) {
        var alias = variables.retrieveAliasForColumn( arguments.key );
        return variables._nullValues.keyExists( alias ) &&
            compare( variables._nullValues[ alias ], arguments.value ) == 0;
    }

    private any function castValueForGetter( required string key, any value ) {
        arguments.key = variables.retrieveAliasForColumn( arguments.key );
        if ( ! structKeyExists( variables._casts, arguments.key ) ) {
            return arguments.value;
        }
        switch ( variables._casts[ arguments.key ] ) {
            case "boolean":
                return javacast( "boolean", arguments.value );
            default:
                return arguments.value;
        }
        return this;
    }

    private any function castValueForSetter( required string key, any value ) {
        arguments.key = variables.retrieveAliasForColumn( arguments.key );
        if ( ! structKeyExists( variables._casts, arguments.key ) ) {
            return arguments.value;
        }
        switch ( variables._casts[ arguments.key ] ) {
            case "boolean":
                return arguments.value ? 1 : 0;
            default:
                return arguments.value;
        }
        return this;
    }

    private boolean function canUpdateAttribute( required string name ) {
        var alias = variables.retrieveAliasForColumn( arguments.name );
        return variables._meta.properties.keyExists( alias ) &&
            variables._meta.properties[ alias ].update;
    }

    private boolean function canInsertAttribute( required string name ) {
        var alias = variables.retrieveAliasForColumn( arguments.name );
        return variables._meta.properties.keyExists( alias ) &&
            variables._meta.properties[ alias ].insert;
    }

}
