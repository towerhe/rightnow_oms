
(function(exports) {
window.DS = Ember.Namespace.create({
  CURRENT_API_REVISION: 1
});

})({});


(function(exports) {
DS.Adapter = Ember.Object.extend({
  commit: function(store, commitDetails) {
    commitDetails.updated.eachType(function(type, array) {
      this.updateRecords(store, type, array.slice());
    }, this);

    commitDetails.created.eachType(function(type, array) {
      this.createRecords(store, type, array.slice());
    }, this);

    commitDetails.deleted.eachType(function(type, array) {
      this.deleteRecords(store, type, array.slice());
    }, this);
  },

  createRecords: function(store, type, models) {
    models.forEach(function(model) {
      this.createRecord(store, type, model);
    }, this);
  },

  updateRecords: function(store, type, models) {
    models.forEach(function(model) {
      this.updateRecord(store, type, model);
    }, this);
  },

  deleteRecords: function(store, type, models) {
    models.forEach(function(model) {
      this.deleteRecord(store, type, model);
    }, this);
  },

  findMany: function(store, type, ids) {
    ids.forEach(function(id) {
      this.find(store, type, id);
    }, this);
  }
});
})({});


(function(exports) {
DS.fixtureAdapter = DS.Adapter.create({
  find: function(store, type, id) {
    var fixtures = type.FIXTURES;

    ember_assert("Unable to find fixtures for model type "+type.toString(), !!fixtures);
    if (fixtures.hasLoaded) { return; }

    setTimeout(function() {
      store.loadMany(type, fixtures);
      fixtures.hasLoaded = true;
    }, 300);
  },

  findMany: function() {
    this.find.apply(this, arguments);
  },

  findAll: function(store, type) {
    var fixtures = type.FIXTURES;

    ember_assert("Unable to find fixtures for model type "+type.toString(), !!fixtures);

    var ids = fixtures.map(function(item, index, self){ return item.id; });
    store.loadMany(type, ids, fixtures);
  }

});

})({});


(function(exports) {
/*global jQuery*/
var get = Ember.get, set = Ember.set, getPath = Ember.getPath;

DS.RESTAdapter = DS.Adapter.extend({
  createRecord: function(store, type, model) {
    var root = this.rootForType(type);

    var data = {};
    data[root] = model.toJSON();

    this.ajax("/" + this.pluralize(root), "POST", {
      data: data,
      success: function(json) {
        this.sideload(store, type, json, root);
        store.didCreateRecord(model, json[root]);
      }
    });
  },

  createRecords: function(store, type, models) {
    if (get(this, 'bulkCommit') === false) {
      return this._super(store, type, models);
    }

    var root = this.rootForType(type),
        plural = this.pluralize(root);

    var data = {};
    data[plural] = models.map(function(model) {
      return model.toJSON();
    });

    this.ajax("/" + this.pluralize(root), "POST", {
      data: data,

      success: function(json) {
        this.sideload(store, type, json, plural);
        store.didCreateRecords(type, models, json[plural]);
      }
    });
  },

  updateRecord: function(store, type, model) {
    var id = get(model, 'id');
    var root = this.rootForType(type);

    var data = {};
    data[root] = model.toJSON();

    var url = ["", this.pluralize(root), id].join("/");

    this.ajax(url, "PUT", {
      data: data,
      success: function(json) {
        this.sideload(store, type, json, root);
        store.didUpdateRecord(model, json[root]);
      }
    });
  },

  updateRecords: function(store, type, models) {
    if (get(this, 'bulkCommit') === false) {
      return this._super(store, type, models);
    }

    var root = this.rootForType(type),
        plural = this.pluralize(root);

    var data = {};
    data[plural] = models.map(function(model) {
      return model.toJSON();
    });

    this.ajax("/" + this.pluralize(root) + "/bulk", "PUT", {
      data: data,
      success: function(json) {
        this.sideload(store, type, json, plural);
        store.didUpdateRecords(models, json[plural]);
      }
    });
  },

  deleteRecord: function(store, type, model) {
    var id = get(model, 'id');
    var root = this.rootForType(type);

    var url = ["", this.pluralize(root), id].join("/");

    this.ajax(url, "DELETE", {
      success: function(json) {
        if (json) { this.sideload(store, type, json); }
        store.didDeleteRecord(model);
      }
    });
  },

  deleteRecords: function(store, type, models) {
    if (get(this, 'bulkCommit') === false) {
      return this._super(store, type, models);
    }

    var root = this.rootForType(type),
        plural = this.pluralize(root);

    var data = {};
    data[plural] = models.map(function(model) {
      return get(model, 'id');
    });

    this.ajax("/" + this.pluralize(root) + "/bulk", "DELETE", {
      data: data,
      success: function(json) {
        if (json) { this.sideload(store, type, json); }
        store.didDeleteRecords(models);
      }
    });
  },

  find: function(store, type, id) {
    var root = this.rootForType(type);

    var url = ["", this.pluralize(root), id].join("/");

    this.ajax(url, "GET", {
      success: function(json) {
        store.load(type, json[root]);
        this.sideload(store, type, json, root);
      }
    });
  },

  findMany: function(store, type, ids) {
    var root = this.rootForType(type), plural = this.pluralize(root);

    this.ajax("/" + plural, "GET", {
      data: { ids: ids },
      success: function(json) {
        store.loadMany(type, ids, json[plural]);
        this.sideload(store, type, json, plural);
      }
    });
  },

  findAll: function(store, type) {
    var root = this.rootForType(type), plural = this.pluralize(root);

    this.ajax("/" + plural, "GET", {
      success: function(json) {
        store.loadMany(type, json[plural]);
        this.sideload(store, type, json, plural);
      }
    });
  },

  findQuery: function(store, type, query, modelArray) {
    var root = this.rootForType(type), plural = this.pluralize(root);

    this.ajax("/" + plural, "GET", {
      data: query,
      success: function(json) {
        modelArray.load(json[plural]);
        this.sideload(store, type, json, plural);
      }
    });
  },

  // HELPERS

  plurals: {},

  // define a plurals hash in your subclass to define
  // special-case pluralization
  pluralize: function(name) {
    return this.plurals[name] || name + "s";
  },

  rootForType: function(type) {
    if (type.url) { return type.url; }

    // use the last part of the name as the URL
    var parts = type.toString().split(".");
    var name = parts[parts.length - 1];
    return name.replace(/([A-Z])/g, '_$1').toLowerCase().slice(1);
  },

  ajax: function(url, type, hash) {
    hash.url = url;
    hash.type = type;
    hash.dataType = 'json';
    hash.contentType = 'application/json';
    hash.context = this;

    if (hash.data && type !== 'GET') {
      hash.data = JSON.stringify(hash.data);
    }

    jQuery.ajax(hash);
  },

  sideload: function(store, type, json, root) {
    var sideloadedType, mappings;

    for (var prop in json) {
      if (!json.hasOwnProperty(prop)) { continue; }
      if (prop === root) { continue; }

      sideloadedType = type.typeForAssociation(prop);

      if (!sideloadedType) {
        mappings = get(this, 'mappings');

        ember_assert("Your server returned a hash with the key " + prop + " but you have no mappings", !!mappings);

        sideloadedType = get(get(this, 'mappings'), prop);

        ember_assert("Your server returned a hash with the key " + prop + " but you have no mapping for it", !!sideloadedType);
      }

      this.loadValue(store, sideloadedType, json[prop]);
    }
  },

  loadValue: function(store, type, value) {
    if (value instanceof Array) {
      store.loadMany(type, value);
    } else {
      store.load(type, value);
    }
  }
});


})({});


(function(exports) {
var get = Ember.get, set = Ember.set;

/**
  A model array is an array that contains records of a certain type. The model
  array materializes records as needed when they are retrieved for the first
  time. You should not create model arrays yourself. Instead, an instance of
  DS.ModelArray or its subclasses will be returned by your application's store
  in response to queries.
*/

DS.ModelArray = Ember.ArrayProxy.extend({

  /**
    The model type contained by this model array.

    @type DS.Model
  */
  type: null,

  // The array of client ids backing the model array. When a
  // record is requested from the model array, the record
  // for the client id at the same index is materialized, if
  // necessary, by the store.
  content: null,

  // The store that created this model array.
  store: null,

  init: function() {
    set(this, 'modelCache', Ember.A([]));
    this._super();
  },

  arrayDidChange: function(array, index, removed, added) {
    var modelCache = get(this, 'modelCache');
    modelCache.replace(index, 0, new Array(added));

    this._super(array, index, removed, added);
  },

  arrayWillChange: function(array, index, removed, added) {
    this._super(array, index, removed, added);

    var modelCache = get(this, 'modelCache');
    modelCache.replace(index, removed);
  },

  objectAtContent: function(index) {
    var modelCache = get(this, 'modelCache');
    var model = modelCache.objectAt(index);

    if (!model) {
      var store = get(this, 'store');
      var content = get(this, 'content');

      var contentObject = content.objectAt(index);

      if (contentObject !== undefined) {
        model = store.findByClientId(get(this, 'type'), contentObject);
        modelCache.replace(index, 1, [model]);
      }
    }

    return model;
  }
});

})({});


(function(exports) {
var get = Ember.get;

DS.FilteredModelArray = DS.ModelArray.extend({
  filterFunction: null,

  replace: function() {
    var type = get(this, 'type').toString();
    throw new Error("The result of a client-side filter (on " + type + ") is immutable.");
  },

  updateFilter: Ember.observer(function() {
    var store = get(this, 'store');
    store.updateModelArrayFilter(this, get(this, 'type'), get(this, 'filterFunction'));
  }, 'filterFunction')
});

})({});


(function(exports) {
var get = Ember.get, set = Ember.set;

DS.AdapterPopulatedModelArray = DS.ModelArray.extend({
  query: null,
  isLoaded: false,

  replace: function() {
    var type = get(this, 'type').toString();
    throw new Error("The result of a server query (on " + type + ") is immutable.");
  },

  load: function(array) {
    var store = get(this, 'store'), type = get(this, 'type');

    var clientIds = store.loadMany(type, array).clientIds;

    this.beginPropertyChanges();
    set(this, 'content', Ember.A(clientIds));
    set(this, 'isLoaded', true);
    this.endPropertyChanges();
  }
});


})({});


(function(exports) {
var get = Ember.get, set = Ember.set;

DS.ManyArray = DS.ModelArray.extend({
  parentRecord: null,

  // Overrides Ember.Array's replace method to implement
  replace: function(index, removed, added) {
    var parentRecord = get(this, 'parentRecord');
    var pendingParent = parentRecord && !get(parentRecord, 'id');

    added = added.map(function(item) {
      ember_assert("You can only add items of " + (get(this, 'type') && get(this, 'type').toString()) + " to this association.", !get(this, 'type') || (get(this, 'type') === item.constructor));

      if (pendingParent) { item.send('waitingOn', parentRecord); }
      return item.get('clientId');
    });

    this._super(index, removed, added);
  }
});

})({});


(function(exports) {
})({});


(function(exports) {
var get = Ember.get, set = Ember.set, getPath = Ember.getPath, fmt = Ember.String.fmt;

DS.Transaction = Ember.Object.extend({
  init: function() {
    set(this, 'buckets', {
      clean:   Ember.Map.create(),
      created: Ember.Map.create(),
      updated: Ember.Map.create(),
      deleted: Ember.Map.create()
    });
  },

  createRecord: function(type, hash) {
    var store = get(this, 'store');

    return store.createRecord(type, hash, this);
  },

  add: function(record) {
    // we could probably make this work if someone has a valid use case. Do you?
    ember_assert("Once a record has changed, you cannot move it into a different transaction", !get(record, 'isDirty'));

    var modelTransaction = get(record, 'transaction'),
        defaultTransaction = getPath(this, 'store.defaultTransaction');

    ember_assert("Models cannot belong to more than one transaction at a time.", modelTransaction === defaultTransaction);

    this.adoptRecord(record);
  },

  remove: function(record) {
    var defaultTransaction = getPath(this, 'store.defaultTransaction');

    defaultTransaction.adoptRecord(record);
  },

  /**
    @private

    This method moves a record into a different transaction without the normal
    checks that ensure that the user is not doing something weird, like moving
    a dirty record into a new transaction.

    It is designed for internal use, such as when we are moving a clean record
    into a new transaction when the transaction is committed.

    This method must not be called unless the record is clean.
  */
  adoptRecord: function(record) {
    var oldTransaction = get(record, 'transaction');

    if (oldTransaction) {
      oldTransaction.removeFromBucket('clean', record);
    }

    this.addToBucket('clean', record);
    set(record, 'transaction', this);
  },

  modelBecameDirty: function(kind, record) {
    this.removeFromBucket('clean', record);
    this.addToBucket(kind, record);
  },

  /** @private */
  addToBucket: function(kind, record) {
    var bucket = get(get(this, 'buckets'), kind),
        type = record.constructor;

    var records = bucket.get(type);

    if (!records) {
      records = Ember.OrderedSet.create();
      bucket.set(type, records);
    }

    records.add(record);
  },

  /** @private */
  removeFromBucket: function(kind, record) {
    var bucket = get(get(this, 'buckets'), kind),
        type = record.constructor;

    var records = bucket.get(type);
    records.remove(record);
  },

  modelBecameClean: function(kind, record) {
    this.removeFromBucket(kind, record);

    var defaultTransaction = getPath(this, 'store.defaultTransaction');
    defaultTransaction.adoptRecord(record);
  },

  commit: function() {
    var buckets = get(this, 'buckets');

    var iterate = function(kind, fn, binding) {
      var dirty = get(buckets, kind);

      dirty.forEach(function(type, models) {
        if (models.isEmpty()) { return; }

        var array = [];

        models.forEach(function(model) {
          model.send('willCommit');

          if (get(model, 'isPending') === false) {
            array.push(model);
          }
        });

        fn.call(binding, type, array);
      });
    };

    var commitDetails = {
      updated: {
        eachType: function(fn, binding) { iterate('updated', fn, binding); }
      },

      created: {
        eachType: function(fn, binding) { iterate('created', fn, binding); }
      },

      deleted: {
        eachType: function(fn, binding) { iterate('deleted', fn, binding); }
      }
    };

    var store = get(this, 'store');
    var adapter = get(store, '_adapter');

    var clean = get(buckets, 'clean');
    var defaultTransaction = get(store, 'defaultTransaction');

    clean.forEach(function(type, records) {
      records.forEach(function(record) {
        this.remove(record);
      }, this);
    }, this);

    if (adapter && adapter.commit) { adapter.commit(store, commitDetails); }
    else { throw fmt("Adapter is either null or do not implement `commit` method", this); }
  }
});

})({});


(function(exports) {
var get = Ember.get, set = Ember.set, getPath = Ember.getPath, fmt = Ember.String.fmt;

var DATA_PROXY = {
  get: function(name) {
    return this.savedData[name];
  }
};


// Implementors Note:
//
//   The variables in this file are consistently named according to the following
//   scheme:
//
//   * +id+ means an identifier managed by an external source, provided inside the
//     data hash provided by that source.
//   * +clientId+ means a transient numerical identifier generated at runtime by
//     the data store. It is important primarily because newly created objects may
//     not yet have an externally generated id.
//   * +type+ means a subclass of DS.Model.

/**
  The store contains all of the hashes for data models loaded from the server.
  It is also responsible for creating instances of DS.Model when you request one
  of these data hashes, so that they can be bound to in your Handlebars templates.

  Create a new store like this:

       MyApp.store = DS.Store.create();

  You can retrieve DS.Model instances from the store in several ways. To retrieve
  a model for a specific id, use the `find()` method:

       var model = MyApp.store.find(MyApp.Contact, 123);

   By default, the store will talk to your backend using a standard REST mechanism.
   You can customize how the store talks to your backend by specifying a custom adapter:

       MyApp.store = DS.Store.create({
         adapter: 'MyApp.CustomAdapter'
       });

    You can learn more about writing a custom adapter by reading the `DS.Adapter`
    documentation.
*/
DS.Store = Ember.Object.extend({

  /**
    Many methods can be invoked without specifying which store should be used.
    In those cases, the first store created will be used as the default. If
    an application has multiple stores, it should specify which store to use
    when performing actions, such as finding records by id.

    The init method registers this store as the default if none is specified.
  */
  init: function() {
    // Enforce API revisioning. See BREAKING_CHANGES.md for more.
    var revision = get(this, 'revision');

    if (revision !== DS.CURRENT_API_REVISION && !Ember.ENV.TESTING) {
      throw new Error("Error: The Ember Data library has had breaking API changes since the last time you updated the library. Please review the list of breaking changes at https://github.com/emberjs/data/blob/master/BREAKING_CHANGES.md, then update your store's `revision` property to " + DS.CURRENT_API_REVISION);
    }

    if (!get(DS, 'defaultStore') || get(this, 'isDefaultStore')) {
      set(DS, 'defaultStore', this);
    }

    set(this, '_typeMap', {});
    set(this, 'recordCache', []);
    set(this, 'modelArrays', []);
    set(this, 'modelArraysByClientId', {});
    set(this, 'defaultTransaction', this.transaction());

    return this._super();
  },

  transaction: function() {
    return DS.Transaction.create({ store: this });
  },

  modelArraysForClientId: function(clientId) {
    var modelArrays = get(this, 'modelArraysByClientId');
    var ret = modelArrays[clientId];

    if (!ret) {
      ret = modelArrays[clientId] = Ember.OrderedSet.create();
    }

    return ret;
  },

  /**
    The adapter to use to communicate to a backend server or other persistence layer.

    This can be specified as an instance, a class, or a property path that specifies
    where the adapter can be located.

    @property {DS.Adapter|String}
  */
  adapter: null,

  _adapter: Ember.computed(function() {
    var adapter = get(this, 'adapter');
    if (typeof adapter === 'string') {
      return getPath(this, adapter, false) || getPath(window, adapter);
    }
    return adapter;
  }).property('adapter').cacheable(),

  clientIdCounter: -1,

  // ....................
  // . CREATE NEW MODEL .
  // ....................

  createRecord: function(type, properties, transaction) {
    properties = properties || {};

    // Create a new instance of the model `type` and put it
    // into the specified `transaction`. If no transaction is
    // specified, the default transaction will be used.
    //
    // NOTE: A `transaction` is specified when the
    // `transaction.createRecord` API is used.
    var record = type._create({
      store: this
    });

    transaction = transaction || get(this, 'defaultTransaction');
    transaction.adoptRecord(record);

    // Extract the primary key from the `properties` hash,
    // based on the `primaryKey` for the model type.
    var id = properties[get(record, 'primaryKey')] || null;

    var hash = {}, clientId;

    // Push the hash into the store. If present, associate the
    // extracted `id` with the hash.
    clientId = this.pushHash(hash, id, type);

    record.send('didChangeData');

    var recordCache = get(this, 'recordCache');

    // Now that we have a clientId, attach it to the record we
    // just created.
    set(record, 'clientId', clientId);

    // Store the record we just created in the record cache for
    // this clientId.
    recordCache[clientId] = record;

    // Set the properties specified on the record.
    record.setProperties(properties);

    this.updateModelArrays(type, clientId, get(record, 'data'));

    return record;
  },

  // ................
  // . DELETE MODEL .
  // ................

  deleteRecord: function(model) {
    model.send('deleteRecord');
  },

  // ...............
  // . FIND MODELS .
  // ...............

  /**
    Finds a model by its id. If the data for that model has already been
    loaded, an instance of DS.Model with that data will be returned
    immediately. Otherwise, an empty DS.Model instance will be returned in
    the loading state. As soon as the requested data is available, the model
    will be moved into the loaded state and all of the information will be
    available.

    Note that only one DS.Model instance is ever created per unique id for a
    given type.

    Example:

        var record = MyApp.store.find(MyApp.Person, 1234);

    @param {DS.Model} type
    @param {String|Number} id
  */
  find: function(type, id, query) {
    if (id === undefined) {
      return this.findAll(type);
    }

    if (query !== undefined) {
      return this.findMany(type, id, query);
    } else if (Ember.typeOf(id) === 'object') {
      return this.findQuery(type, id);
    }

    if (Ember.isArray(id)) {
      return this.findMany(type, id);
    }

    var clientId = this.clientIdForId(type, id);

    return this.findByClientId(type, clientId, id);
  },

  findByClientId: function(type, clientId, id) {
    var model;

    var recordCache = get(this, 'recordCache');
    var dataCache = this.clientIdToHashMap(type);

    // If there is already a clientId assigned for this
    // type/id combination, try to find an existing
    // model for that id and return. Otherwise,
    // materialize a new model and set its data to the
    // value we already have.
    if (clientId !== undefined) {
      model = recordCache[clientId];

      if (!model) {
        // create a new instance of the model in the
        // 'isLoading' state
        model = this.materializeRecord(type, clientId);

        if (dataCache[clientId]) {
          model.send('didChangeData');
        }
      }
    } else {
      clientId = this.pushHash(null, id, type);

      // create a new instance of the model in the
      // 'isLoading' state
      model = this.materializeRecord(type, clientId);

      // let the adapter set the data, possibly async
      var adapter = get(this, '_adapter');
      if (adapter && adapter.find) { adapter.find(this, type, id); }
      else { throw fmt("Adapter is either null or does not implement `find` method", this); }
    }

    return model;
  },

  /** @private
  */
  findMany: function(type, ids, query) {
    var idToClientIdMap = this.idToClientIdMap(type);
    var data = this.clientIdToHashMap(type), needed;

    var clientIds = Ember.A([]);

    if (ids) {
      needed = [];

      ids.forEach(function(id) {
        var clientId = idToClientIdMap[id];
        if (clientId === undefined || data[clientId] === undefined) {
          clientId = this.pushHash(null, id, type);
          needed.push(id);
        }

        clientIds.push(clientId);
      }, this);
    } else {
      needed = null;
    }

    if ((needed && get(needed, 'length') > 0) || query) {
      var adapter = get(this, '_adapter');
      if (adapter && adapter.findMany) { adapter.findMany(this, type, needed, query); }
      else { throw fmt("Adapter is either null or does not implement `findMany` method", this); }
    }

    return this.createManyArray(type, clientIds);
  },

  findQuery: function(type, query) {
    var array = DS.AdapterPopulatedModelArray.create({ type: type, content: Ember.A([]), store: this });
    var adapter = get(this, '_adapter');
    if (adapter && adapter.findQuery) { adapter.findQuery(this, type, query, array); }
    else { throw fmt("Adapter is either null or does not implement `findQuery` method", this); }
    return array;
  },

  findAll: function(type) {

    var typeMap = this.typeMapFor(type),
        findAllCache = typeMap.findAllCache;

    if (findAllCache) { return findAllCache; }

    var array = DS.ModelArray.create({ type: type, content: Ember.A([]), store: this });
    this.registerModelArray(array, type);

    var adapter = get(this, '_adapter');
    if (adapter && adapter.findAll) { adapter.findAll(this, type); }

    typeMap.findAllCache = array;
    return array;
  },

  filter: function(type, filter) {
    var array = DS.FilteredModelArray.create({ type: type, content: Ember.A([]), store: this, filterFunction: filter });

    this.registerModelArray(array, type, filter);

    return array;
  },

  // ............
  // . UPDATING .
  // ............

  hashWasUpdated: function(type, clientId, record) {
    this.updateModelArrays(type, clientId, get(record, 'data'));
  },

  // ..............
  // . PERSISTING .
  // ..............

  commit: function() {
    var defaultTransaction = get(this, 'defaultTransaction');
    set(this, 'defaultTransaction', this.transaction());

    defaultTransaction.commit();
  },

  didUpdateRecords: function(array, hashes) {
    if (arguments.length === 2) {
      array.forEach(function(model, idx) {
        this.didUpdateRecord(model, hashes[idx]);
      }, this);
    } else {
      array.forEach(function(model) {
        this.didUpdateRecord(model);
      }, this);
    }
  },

  didUpdateRecord: function(model, hash) {
    if (arguments.length === 2) {
      var clientId = get(model, 'clientId');
      var data = this.clientIdToHashMap(model.constructor);

      data[clientId] = hash;
      model.send('didChangeData');
    }

    model.send('didCommit');
  },

  didDeleteRecords: function(array) {
    array.forEach(function(model) {
      model.send('didCommit');
    });
  },

  didDeleteRecord: function(model) {
    model.send('didCommit');
  },

  _didCreateRecord: function(record, hash, dataCache, clientId, primaryKey, idMap, idList) {
    var recordData = get(record, 'data'), id, changes;

    if (hash) {
      dataCache[clientId] = hash;

      // If the server returns a hash, we assume that the server's version
      // of the data supercedes the local changes.
      record.beginPropertyChanges();
      record.send('didChangeData');
      recordData.adapterDidUpdate(hash);
      record.endPropertyChanges();

      id = hash[primaryKey];

      idMap[id] = clientId;
      idList.push(id);
    } else {
      recordData.commit();
    }

    record.send('didCommit');
  },


  didCreateRecords: function(type, array, hashes) {
    var id, clientId, primaryKey = getPath(type, 'proto.primaryKey');

    var idToClientIdMap = this.idToClientIdMap(type);
    var data = this.clientIdToHashMap(type);
    var idList = this.idList(type);

    for (var i=0, l=get(array, 'length'); i<l; i++) {
      var model = array[i], hash = hashes[i];
      clientId = get(model, 'clientId');

      this._didCreateRecord(model, hash, data, clientId, primaryKey, idToClientIdMap, idList);
    }
  },

  didCreateRecord: function(model, hash) {
    var type = model.constructor;

    var id, clientId, primaryKey;

    var idToClientIdMap = this.idToClientIdMap(type);
    var data = this.clientIdToHashMap(type);
    var idList = this.idList(type);

    // The hash is optional, but if it is not provided, the client must have
    // provided a primary key.

    primaryKey = getPath(type, 'proto.primaryKey');

    // TODO: Make ember_assert more flexible and convert this into an ember_assert
    if (hash) {
      ember_assert("The server must provide a primary key: " + primaryKey, get(hash, primaryKey));
    } else {
      ember_assert("The server did not return data, and you did not create a primary key (" + primaryKey + ") on the client", get(get(model, 'data'), primaryKey));
    }

    clientId = get(model, 'clientId');

    this._didCreateRecord(model, hash, data, clientId, primaryKey, idToClientIdMap, idList);
  },

  recordWasInvalid: function(record, errors) {
    record.send('becameInvalid', errors);
  },

  // ................
  // . MODEL ARRAYS .
  // ................

  registerModelArray: function(array, type, filter) {
    var modelArrays = get(this, 'modelArrays');

    modelArrays.push(array);

    this.updateModelArrayFilter(array, type, filter);
  },

  createManyArray: function(type, clientIds) {
    var array = DS.ManyArray.create({ type: type, content: clientIds, store: this });

    clientIds.forEach(function(clientId) {
      var modelArrays = this.modelArraysForClientId(clientId);
      modelArrays.add(array);
    }, this);

    return array;
  },

  updateModelArrayFilter: function(array, type, filter) {
    var dataCache = this.clientIdToHashMap(type);
    var allClientIds = this.clientIdList(type), clientId, hash, proxy;

    var recordCache = get(this, 'recordCache'), record;

    for (var i=0, l=allClientIds.length; i<l; i++) {
      clientId = allClientIds[i];

      hash = dataCache[clientId];

      if (hash = dataCache[clientId]) {
        if (record = recordCache[clientId]) {
          proxy = get(record, 'data');
        } else {
          DATA_PROXY.savedData = hash;
          proxy = DATA_PROXY;
        }

        this.updateModelArray(array, filter, type, clientId, proxy);
      }
    }
  },

  updateModelArrays: function(type, clientId, dataProxy) {
    var modelArrays = get(this, 'modelArrays'),
        modelArrayType, filter;

    modelArrays.forEach(function(array) {
      modelArrayType = get(array, 'type');
      filter = get(array, 'filterFunction');

      if (type !== modelArrayType) { return; }

      this.updateModelArray(array, filter, type, clientId, dataProxy);
    }, this);
  },

  updateModelArray: function(array, filter, type, clientId, dataProxy) {
    var shouldBeInArray;

    if (!filter) {
      shouldBeInArray = true;
    } else {
      shouldBeInArray = filter(dataProxy);
    }

    var content = get(array, 'content');
    var alreadyInArray = content.indexOf(clientId) !== -1;

    var modelArrays = this.modelArraysForClientId(clientId);

    if (shouldBeInArray && !alreadyInArray) {
      modelArrays.add(array);
      content.pushObject(clientId);
    } else if (!shouldBeInArray && alreadyInArray) {
      modelArrays.remove(array);
      content.removeObject(clientId);
    }
  },

  removeFromModelArrays: function(model) {
    var clientId = get(model, 'clientId');
    var modelArrays = this.modelArraysForClientId(clientId);

    modelArrays.forEach(function(array) {
      var content = get(array, 'content');
      content.removeObject(clientId);
    });
  },

  // ............
  // . TYPE MAP .
  // ............

  typeMapFor: function(type) {
    var ids = get(this, '_typeMap');
    var guidForType = Ember.guidFor(type);

    var typeMap = ids[guidForType];

    if (typeMap) {
      return typeMap;
    } else {
      return (ids[guidForType] =
        {
          idToCid: {},
          idList: [],
          cidList: [],
          cidToHash: {}
      });
    }
  },

  idToClientIdMap: function(type) {
    return this.typeMapFor(type).idToCid;
  },

  idList: function(type) {
    return this.typeMapFor(type).idList;
  },

  clientIdList: function(type) {
    return this.typeMapFor(type).cidList;
  },

  clientIdToHashMap: function(type) {
    return this.typeMapFor(type).cidToHash;
  },

  dataForClientId: function(type, clientId) {
    return this.clientIdToHashMap(type)[clientId];
  },

  /** @private

    For a given type and id combination, returns the client id used by the store.
    If no client id has been assigned yet, `undefined` is returned.

    @param {DS.Model} type
    @param {String|Number} id
  */
  clientIdForId: function(type, id) {
    return this.typeMapFor(type).idToCid[id];
  },

  idForHash: function(type, hash) {
    var primaryKey = getPath(type, 'proto.primaryKey');

    ember_assert("A data hash was loaded for a model of type " + type.toString() + " but no primary key '" + primaryKey + "' was provided.", !!hash[primaryKey]);
    return hash[primaryKey];
  },

  // ................
  // . LOADING DATA .
  // ................

  /**
    Load a new data hash into the store for a given id and type combination.
    If data for that model had been loaded previously, the new information
    overwrites the old.

    If the model you are loading data for has outstanding changes that have not
    yet been saved, an exception will be thrown.

    @param {DS.Model} type
    @param {String|Number} id
    @param {Object} hash the data hash to load
  */
  load: function(type, id, hash) {
    if (hash === undefined) {
      hash = id;
      var primaryKey = getPath(type, 'proto.primaryKey');
      ember_assert("A data hash was loaded for a model of type " + type.toString() + " but no primary key '" + primaryKey + "' was provided.", primaryKey in hash);
      id = hash[primaryKey];
    }

    var data = this.clientIdToHashMap(type);
    var recordCache = get(this, 'recordCache');

    var clientId = this.clientIdForId(type, id);

    if (clientId !== undefined) {
      data[clientId] = hash;

      var model = recordCache[clientId];
      if (model) {
        model.send('didChangeData');
      }
    } else {
      clientId = this.pushHash(hash, id, type);
    }

    DATA_PROXY.savedData = hash;
    this.updateModelArrays(type, clientId, DATA_PROXY);

    return { id: id, clientId: clientId };
  },

  loadMany: function(type, ids, hashes) {
    var clientIds = Ember.A([]);

    if (hashes === undefined) {
      hashes = ids;
      ids = [];
      var primaryKey = getPath(type, 'proto.primaryKey');

      ids = hashes.map(function(hash) {
        ember_assert("A data hash was loaded for a model of type " + type.toString() + " but no primary key '" + primaryKey + "' was provided.", !!hash[primaryKey]);
        return hash[primaryKey];
      });
    }

    for (var i=0, l=get(ids, 'length'); i<l; i++) {
      var loaded = this.load(type, ids[i], hashes[i]);
      clientIds.pushObject(loaded.clientId);
    }

    return { clientIds: clientIds, ids: ids };
  },

  /** @private

    Stores a data hash for the specified type and id combination and returns
    the client id.

    @param {Object} hash
    @param {String|Number} id
    @param {DS.Model} type
    @returns {Number}
  */
  pushHash: function(hash, id, type) {
    var idToClientIdMap = this.idToClientIdMap(type);
    var clientIdList = this.clientIdList(type);
    var idList = this.idList(type);
    var data = this.clientIdToHashMap(type);

    var clientId = this.incrementProperty('clientIdCounter');

    data[clientId] = hash;

    // if we're creating an item, this process will be done
    // later, once the object has been persisted.
    if (id) {
      idToClientIdMap[id] = clientId;
      idList.push(id);
    }

    clientIdList.push(clientId);

    return clientId;
  },

  // .........................
  // . MODEL MATERIALIZATION .
  // .........................

  materializeRecord: function(type, clientId) {
    var model;

    get(this, 'recordCache')[clientId] = model = type._create({
      store: this,
      clientId: clientId
    });

    get(this, 'defaultTransaction').adoptRecord(model);

    model.send('loadingData');
    return model;
  },

  destroy: function() {
    if (get(DS, 'defaultStore') === this) {
      set(DS, 'defaultStore', null);
    }

    return this._super();
  }
});

})({});


(function(exports) {
var get = Ember.get, set = Ember.set, getPath = Ember.getPath, guidFor = Ember.guidFor;

var stateProperty = Ember.computed(function(key) {
  var parent = get(this, 'parentState');
  if (parent) {
    return get(parent, key);
  }
}).property();

var isEmptyObject = function(object) {
  for (var name in object) {
    if (object.hasOwnProperty(name)) { return false; }
  }

  return true;
};

var hasDefinedProperties = function(object) {
  for (var name in object) {
    if (object.hasOwnProperty(name) && object[name]) { return true; }
  }

  return false;
};

DS.State = Ember.State.extend({
  isLoaded: stateProperty,
  isDirty: stateProperty,
  isSaving: stateProperty,
  isDeleted: stateProperty,
  isError: stateProperty,
  isNew: stateProperty,
  isValid: stateProperty,
  isPending: stateProperty,

  // For states that are substates of a
  // DirtyState (updated or created), it is
  // useful to be able to determine which
  // type of dirty state it is.
  dirtyType: stateProperty
});

var setProperty = function(manager, context) {
  var key = context.key, value = context.value;

  var model = get(manager, 'model'),
      data = get(model, 'data');

  set(data, key, value);
};

var didChangeData = function(manager) {
  var model = get(manager, 'model'),
      data = get(model, 'data');

  data._savedData = null;
  model.notifyPropertyChange('data');
};

// The waitingOn event shares common functionality
// between the different dirty states, but each is
// treated slightly differently. This method is exposed
// so that each implementation can invoke the common
// behavior, and then implement the behavior specific
// to the state.
var waitingOn = function(manager, object) {
  var model = get(manager, 'model'),
      pendingQueue = get(model, 'pendingQueue'),
      objectGuid = guidFor(object);

  var observer = function() {
    if (get(object, 'id')) {
      manager.send('doneWaitingOn', object);
      Ember.removeObserver(object, 'id', observer);
    }
  };

  pendingQueue[objectGuid] = [object, observer];
  Ember.addObserver(object, 'id', observer);
};

// Implementation notes:
//
// Each state has a boolean value for all of the following flags:
//
// * isLoaded: The record has a populated `data` property. When a
//   record is loaded via `store.find`, `isLoaded` is false
//   until the adapter sets it. When a record is created locally,
//   its `isLoaded` property is always true.
// * isDirty: The record has local changes that have not yet been
//   saved by the adapter. This includes records that have been
//   created (but not yet saved) or deleted.
// * isSaving: The record's transaction has been committed, but
//   the adapter has not yet acknowledged that the changes have
//   been persisted to the backend.
// * isDeleted: The record was marked for deletion. When `isDeleted`
//   is true and `isDirty` is true, the record is deleted locally
//   but the deletion was not yet persisted. When `isSaving` is
//   true, the change is in-flight. When both `isDirty` and
//   `isSaving` are false, the change has persisted.
// * isError: The adapter reported that it was unable to save
//   local changes to the backend. This may also result in the
//   record having its `isValid` property become false if the
//   adapter reported that server-side validations failed.
// * isNew: The record was created on the client and the adapter
//   did not yet report that it was successfully saved.
// * isValid: No client-side validations have failed and the
//   adapter did not report any server-side validation failures.
// * isPending: A record `isPending` when it belongs to an
//   association on another record and that record has not been
//   saved. A record in this state cannot be saved because it
//   lacks a "foreign key" that will be supplied by its parent
//   association when the parent record has been created. When
//   the adapter reports that the parent has saved, the
//   `isPending` property on all children will become `false`
//   and the transaction will try to commit the records.

// This mixin is mixed into various uncommitted states. Make
// sure to mix it in *after* the class definition, so its
// super points to the class definition.
var Uncommitted = Ember.Mixin.create({
  setProperty: setProperty,

  deleteRecord: function(manager) {
    this._super(manager);

    var model = get(manager, 'model'),
        dirtyType = get(this, 'dirtyType');

    model.withTransaction(function(t) {
      t.modelBecameClean(dirtyType, model);
    });
  }
});

// These mixins are mixed into substates of the concrete
// subclasses of DirtyState.

var CreatedUncommitted = Ember.Mixin.create({
  deleteRecord: function(manager) {
    this._super(manager);

    manager.goToState('deleted.saved');
  }
});

var UpdatedUncommitted = Ember.Mixin.create({
  deleteRecord: function(manager) {
    this._super(manager);

    var model = get(manager, 'model');

    model.withTransaction(function(t) {
      t.modelBecameClean('created', model);
    });

    manager.goToState('deleted');
  }
});

// The dirty state is a abstract state whose functionality is
// shared between the `created` and `updated` states.
//
// The deleted state shares the `isDirty` flag with the
// subclasses of `DirtyState`, but with a very different
// implementation.
var DirtyState = DS.State.extend({
  initialState: 'uncommitted',

  // FLAGS
  isDirty: true,

  // SUBSTATES

  // When a record first becomes dirty, it is `uncommitted`.
  // This means that there are local pending changes,
  // but they have not yet begun to be saved.
  uncommitted: DS.State.extend({
    // TRANSITIONS
    enter: function(manager) {
      var dirtyType = get(this, 'dirtyType'),
          model = get(manager, 'model');

      model.withTransaction(function (t) {
        t.modelBecameDirty(dirtyType, model);
      });
    },

    exit: function(manager) {
      var model = get(manager, 'model');
      manager.send('invokeLifecycleCallbacks', model);
    },

    // EVENTS
    deleteRecord: Ember.K,

    waitingOn: function(manager, object) {
      waitingOn(manager, object);
      manager.goToState('pending');
    },

    willCommit: function(manager) {
      manager.goToState('inFlight');
    }
  }, Uncommitted),

  // Once a record has been handed off to the adapter to be
  // saved, it is in the 'in flight' state. Changes to the
  // record cannot be made during this window.
  inFlight: DS.State.extend({
    // FLAGS
    isSaving: true,

    // TRANSITIONS
    enter: function(manager) {
      var dirtyType = get(this, 'dirtyType'),
          model = get(manager, 'model');

      model.withTransaction(function (t) {
        t.modelBecameClean(dirtyType, model);
      });
    },

    // EVENTS
    didCommit: function(manager) {
      manager.goToState('loaded');
    },

    becameInvalid: function(manager, errors) {
      var model = get(manager, 'model');

      set(model, 'errors', errors);
      manager.goToState('invalid');
    },

    didChangeData: didChangeData
  }),

  // If a record becomes associated with a newly created
  // parent record, it will be `pending` until the parent
  // record has successfully persisted. Once this happens,
  // this record can use the parent's primary key as its
  // foreign key.
  //
  // If the record's transaction had already started to
  // commit, the record will transition to the `inFlight`
  // state. If it had not, the record will transition to
  // the `uncommitted` state.
  pending: DS.State.extend({
    initialState: 'uncommitted',

    // FLAGS
    isPending: true,

    // SUBSTATES

    // A pending record whose transaction has not yet
    // started to commit is in this state.
    uncommitted: DS.State.extend({
      // EVENTS
      deleteRecord: function(manager) {
        var model = get(manager, 'model'),
            pendingQueue = get(model, 'pendingQueue'),
            tuple;

        // since we are leaving the pending state, remove any
        // observers we have registered on other records.
        for (var prop in pendingQueue) {
          if (!pendingQueue.hasOwnProperty(prop)) { continue; }

          tuple = pendingQueue[prop];
          Ember.removeObserver(tuple[0], 'id', tuple[1]);
        }
      },

      willCommit: function(manager) {
        manager.goToState('committing');
      },

      doneWaitingOn: function(manager, object) {
        var model = get(manager, 'model'),
            pendingQueue = get(model, 'pendingQueue'),
            objectGuid = guidFor(object);

        delete pendingQueue[objectGuid];

        if (isEmptyObject(pendingQueue)) {
          manager.send('doneWaiting');
        }
      },

      doneWaiting: function(manager) {
        var dirtyType = get(this, 'dirtyType');
        manager.goToState(dirtyType + '.uncommitted');
      }
    }, Uncommitted),

    // A pending record whose transaction has started
    // to commit is in this state. Since it has not yet
    // been sent to the adapter, it is not `inFlight`
    // until all of its dependencies have been committed.
    committing: DS.State.extend({
      // FLAGS
      isSaving: true,

      // EVENTS
      doneWaitingOn: function(manager, object) {
        var model = get(manager, 'model'),
            pendingQueue = get(model, 'pendingQueue'),
            objectGuid = guidFor(object);

        delete pendingQueue[objectGuid];

        if (isEmptyObject(pendingQueue)) {
          manager.send('doneWaiting');
        }
      },

      doneWaiting: function(manager) {
        var model = get(manager, 'model'),
            transaction = get(model, 'transaction');

        // Now that the model is no longer pending, schedule
        // the transaction to commit.
        Ember.run.once(transaction, transaction.commit);
      },

      willCommit: function(manager) {
        var dirtyType = get(this, 'dirtyType');
        manager.goToState(dirtyType + '.inFlight');
      }
    })
  }),

  // A record is in the `invalid` state when its client-side
  // invalidations have failed, or if the adapter has indicated
  // the the record failed server-side invalidations.
  invalid: DS.State.extend({
    // FLAGS
    isValid: false,

    // EVENTS
    deleteRecord: function(manager) {
      manager.goToState('deleted');
    },

    setProperty: function(manager, context) {
      setProperty(manager, context);

      var model = get(manager, 'model'),
          errors = get(model, 'errors'),
          key = context.key;

      delete errors[key];

      if (!hasDefinedProperties(errors)) {
        manager.send('becameValid');
      }
    },

    becameValid: function(manager) {
      manager.goToState('uncommitted');
    }
  })
});

// The created and updated states are created outside the state
// chart so we can reopen their substates and add mixins as
// necessary.

var createdState = DirtyState.create({
  dirtyType: 'created',

  // FLAGS
  isNew: true,

  // EVENTS
  invokeLifecycleCallbacks: function(manager, model) {
    model.didCreate();
  }
});

var updatedState = DirtyState.create({
  dirtyType: 'updated',

  // EVENTS
  invokeLifecycleCallbacks: function(manager, model) {
    model.didUpdate();
  }
});

// The created.uncommitted state and created.pending.uncommitted share
// some logic defined in CreatedUncommitted.
createdState.states.uncommitted.reopen(CreatedUncommitted);
createdState.states.pending.states.uncommitted.reopen(CreatedUncommitted);

// The updated.uncommitted state and updated.pending.uncommitted share
// some logic defined in UpdatedUncommitted.
updatedState.states.uncommitted.reopen(UpdatedUncommitted);
updatedState.states.pending.states.uncommitted.reopen(UpdatedUncommitted);

var states = {
  rootState: Ember.State.create({
    // FLAGS
    isLoaded: false,
    isDirty: false,
    isSaving: false,
    isDeleted: false,
    isError: false,
    isNew: false,
    isValid: true,
    isPending: false,

    // SUBSTATES

    // A record begins its lifecycle in the `empty` state.
    // If its data will come from the adapter, it will
    // transition into the `loading` state. Otherwise, if
    // the record is being created on the client, it will
    // transition into the `created` state.
    empty: DS.State.create({
      // EVENTS
      loadingData: function(manager) {
        manager.goToState('loading');
      },

      didChangeData: function(manager) {
        didChangeData(manager);

        manager.goToState('loaded.created');
      }
    }),

    // A record enters this state when the store askes
    // the adapter for its data. It remains in this state
    // until the adapter provides the requested data.
    //
    // Usually, this process is asynchronous, using an
    // XHR to retrieve the data.
    loading: DS.State.create({
      // TRANSITIONS
      exit: function(manager) {
        var model = get(manager, 'model');
        model.didLoad();
      },

      // EVENTS
      didChangeData: function(manager, data) {
        didChangeData(manager);
        manager.send('loadedData');
      },

      loadedData: function(manager) {
        manager.goToState('loaded');
      }
    }),

    // A record enters this state when its data is populated.
    // Most of a record's lifecycle is spent inside substates
    // of the `loaded` state.
    loaded: DS.State.create({
      initialState: 'saved',

      // FLAGS
      isLoaded: true,

      // SUBSTATES

      // If there are no local changes to a record, it remains
      // in the `saved` state.
      saved: DS.State.create({
        // EVENTS
        setProperty: function(manager, context) {
          setProperty(manager, context);
          manager.goToState('updated');
        },

        didChangeData: didChangeData,

        deleteRecord: function(manager) {
          manager.goToState('deleted');
        },

        waitingOn: function(manager, object) {
          waitingOn(manager, object);
          manager.goToState('updated.pending');
        }
      }),

      // A record is in this state after it has been locally
      // created but before the adapter has indicated that
      // it has been saved.
      created: createdState,

      // A record is in this state if it has already been
      // saved to the server, but there are new local changes
      // that have not yet been saved.
      updated: updatedState,
    }),

    // A record is in this state if it was deleted from the store.
    deleted: DS.State.create({
      // FLAGS
      isDeleted: true,
      isLoaded: true,
      isDirty: true,

      // SUBSTATES

      // When a record is deleted, it enters the `start`
      // state. It will exit this state when the record's
      // transaction starts to commit.
      start: DS.State.create({
        // TRANSITIONS
        enter: function(manager) {
          var model = get(manager, 'model');
          var store = get(model, 'store');

          if (store) {
            store.removeFromModelArrays(model);
          }

          model.withTransaction(function(t) {
            t.modelBecameDirty('deleted', model);
          });
        },

        // EVENTS
        willCommit: function(manager) {
          manager.goToState('inFlight');
        }
      }),

      // After a record's transaction is committing, but
      // before the adapter indicates that the deletion
      // has saved to the server, a record is in the
      // `inFlight` substate of `deleted`.
      inFlight: DS.State.create({
        // FLAGS
        isSaving: true,

        // TRANSITIONS
        exit: function(stateManager) {
          var model = get(stateManager, 'model');

          model.withTransaction(function(t) {
            t.modelBecameClean('deleted', model);
          });
        },

        // EVENTS
        didCommit: function(manager) {
          manager.goToState('saved');
        }
      }),

      // Once the adapter indicates that the deletion has
      // been saved, the record enters the `saved` substate
      // of `deleted`.
      saved: DS.State.create({
        // FLAGS
        isDirty: false
      })
    }),

    // If the adapter indicates that there was an unknown
    // error saving a record, the record enters the `error`
    // state.
    error: DS.State.create({
      isError: true
    })
  })
};

DS.StateManager = Ember.StateManager.extend({
  model: null,
  initialState: 'rootState',
  states: states
});

})({});


(function(exports) {
var get = Ember.get, set = Ember.set, getPath = Ember.getPath;

var retrieveFromCurrentState = Ember.computed(function(key) {
  return get(getPath(this, 'stateManager.currentState'), key);
}).property('stateManager.currentState').cacheable();

// This object is a regular JS object for performance. It is only
// used internally for bookkeeping purposes.
var DataProxy = function(record) {
  this.record = record;
  this.unsavedData = {};
};

DataProxy.prototype = {
  get: function(key) { return Ember.get(this, key); },
  set: function(key, value) { return Ember.set(this, key, value); },

  // TODO: Memoize
  savedData: function() {
    var savedData = this._savedData;
    if (savedData) { return savedData; }

    var record = this.record,
        clientId = get(record, 'clientId'),
        store = get(record, 'store');

    if (store) {
      savedData = store.dataForClientId(record.constructor, clientId);
      this._savedData = savedData;
      return savedData;
    }
  },

  unknownProperty: function(key) {
    var unsavedData = this.unsavedData,
        savedData = this.savedData();

    var value = unsavedData[key];

    if (savedData && value === undefined) {
      value = savedData[key];
    }

    return value;
  },

  setUnknownProperty: function(key, value) {
    var record = this.record,
        unsavedData = this.unsavedData;

    unsavedData[key] = value;

    // At the end of the run loop, notify model arrays that
    // this record has changed so they can re-evaluate its contents
    // to determine membership.
    Ember.run.once(record, record.notifyHashWasUpdated);

    return value;
  },

  commit: function() {
    var record = this.record;

    var unsavedData = this.unsavedData;
    var savedData = this.savedData();

    for (var prop in unsavedData) {
      if (unsavedData.hasOwnProperty(prop)) {
        savedData[prop] = unsavedData[prop];
        delete unsavedData[prop];
      }
    }

    record.notifyPropertyChange('data');
  },

  rollback: function() {
    this.unsavedData = {};
  },

  adapterDidUpdate: function(data) {
    this.unsavedData = {};
  }
};

DS.Model = Ember.Object.extend({
  isLoaded: retrieveFromCurrentState,
  isDirty: retrieveFromCurrentState,
  isSaving: retrieveFromCurrentState,
  isDeleted: retrieveFromCurrentState,
  isError: retrieveFromCurrentState,
  isNew: retrieveFromCurrentState,
  isPending: retrieveFromCurrentState,
  isValid: retrieveFromCurrentState,

  clientId: null,
  transaction: null,
  stateManager: null,
  pendingQueue: null,
  errors: null,

  // because unknownProperty is used, any internal property
  // must be initialized here.
  primaryKey: 'id',
  id: Ember.computed(function(key, value) {
    var primaryKey = get(this, 'primaryKey'),
        data = get(this, 'data');

    if (arguments.length === 2) {
      set(data, primaryKey, value);
      return value;
    }

    return data && get(data, primaryKey);
  }).property('primaryKey', 'data'),

  toJSON: function() {
    var data = get(this, 'data'),
        result = {},
        type = this.constructor,
        attributes = get(type, 'attributes'),
        associations = get(type, 'associationsByName'),
        primaryKey = get(this, 'primaryKey'),
        id = get(this, 'id');

    if (id) {
      result[primaryKey] = id;
    }

    attributes.forEach(function(name, meta) {
      var key = meta.key || name;

      result[key] = get(data, key);
    }, this);

    return result;
  },

  data: Ember.computed(function() {
    return new DataProxy(this);
  }).cacheable(),

  didLoad: Ember.K,
  didUpdate: Ember.K,
  didCreate: Ember.K,

  init: function() {
    var stateManager = DS.StateManager.create({
      model: this
    });

    set(this, 'pendingQueue', {});

    set(this, 'stateManager', stateManager);
    stateManager.goToState('empty');
  },

  destroy: function() {
    if (!get(this, 'isDeleted')) {
      this.deleteRecord();
    }
    this._super();
  },

  send: function(name, context) {
    return get(this, 'stateManager').send(name, context);
  },

  withTransaction: function(fn) {
    var transaction = get(this, 'transaction');
    if (transaction) { fn(transaction); }
  },

  setProperty: function(key, value) {
    this.send('setProperty', { key: key, value: value });
  },

  deleteRecord: function() {
    this.send('deleteRecord');
  },

  waitingOn: function(record) {
    this.send('waitingOn', record);
  },

  notifyHashWasUpdated: function() {
    var store = get(this, 'store');
    if (store) {
      store.hashWasUpdated(this.constructor, get(this, 'clientId'), this);
    }
  },

  unknownProperty: function(key) {
    var data = get(this, 'data');

    if (data && key in data) {
      ember_assert("You attempted to access the " + key + " property on a model without defining an attribute.", false);
    }
  },

  setUnknownProperty: function(key, value) {
    var data = get(this, 'data');

    if (data && key in data) {
      ember_assert("You attempted to set the " + key + " property on a model without defining an attribute.", false);
    } else {
      return this._super(key, value);
    }
  }
});

// Helper function to generate store aliases.
// This returns a function that invokes the named alias
// on the default store, but injects the class as the
// first parameter.
var storeAlias = function(methodName) {
  return function() {
    var store = get(DS, 'defaultStore'),
        args = [].slice.call(arguments);

    args.unshift(this);
    return store[methodName].apply(store, args);
  };
};

DS.Model.reopenClass({
  find: storeAlias('find'),
  filter: storeAlias('filter'),

  _create: DS.Model.create,

  create: function() {
    throw new Ember.Error("You should not call `create` on a model. Instead, call `createRecord` with the attributes you would like to set.");
  },

  createRecord: storeAlias('createRecord')
});

})({});


(function(exports) {
var get = Ember.get, getPath = Ember.getPath;
DS.Model.reopenClass({
  attributes: Ember.computed(function() {
    var map = Ember.Map.create();

    this.eachComputedProperty(function(name, meta) {
      if (meta.isAttribute) {
        meta.key = meta.key || name;
        map.set(name, meta);
      }
    });

    return map;
  }).cacheable()
});

DS.attr = function(type, options) {
  var transform = DS.attr.transforms[type];
  ember_assert("Could not find model attribute of type " + type, !!transform);

  var transformFrom = transform.from;
  var transformTo = transform.to;

  options = options || {};

  var meta = { type: type, isAttribute: true, key: options.key };

  return Ember.computed(function(key, value) {
    var data;

    key = options.key || key;

    if (arguments.length === 2) {
      value = transformTo(value);
      this.setProperty(key, value);
    } else {
      data = get(this, 'data');
      value = get(data, key);
    }

    return transformFrom(value);
  // `data` is never set directly. However, it may be
  // invalidated from the state manager's setData
  // event.
  }).property('data').cacheable().meta(meta);
};

DS.attr.transforms = {
  string: {
    from: function(serialized) {
      return Ember.none(serialized) ? null : String(serialized);
    },

    to: function(deserialized) {
      return Ember.none(deserialized) ? null : String(deserialized);
    }
  },

  integer: {
    from: function(serialized) {
      return Ember.none(serialized) ? null : Number(serialized);
    },

    to: function(deserialized) {
      return Ember.none(deserialized) ? null : Number(deserialized);
    }
  },

  boolean: {
    from: function(serialized) {
      return Boolean(serialized);
    },

    to: function(deserialized) {
      return Boolean(deserialized);
    }
  },

  date: {
    from: function(serialized) {
      var type = typeof serialized;

      if (type === "string" || type === "number") {
        return new Date(serialized);
      } else if (serialized === null || serialized === undefined) {
        // if the value is not present in the data,
        // return undefined, not null.
        return serialized;
      } else {
        return null;
      }
    },

    to: function(date) {
      if (date instanceof Date) {
        var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

        var pad = function(num) {
          return num < 10 ? "0"+num : ""+num;
        };

        var utcYear = date.getUTCFullYear(),
            utcMonth = date.getUTCMonth(),
            utcDayOfMonth = date.getUTCDate(),
            utcDay = date.getUTCDay(),
            utcHours = date.getUTCHours(),
            utcMinutes = date.getUTCMinutes(),
            utcSeconds = date.getUTCSeconds();


        var dayOfWeek = days[utcDay];
        var dayOfMonth = pad(utcDayOfMonth);
        var month = months[utcMonth];

        return dayOfWeek + ", " + dayOfMonth + " " + month + " " + utcYear + " " +
               pad(utcHours) + ":" + pad(utcMinutes) + ":" + pad(utcSeconds) + " GMT";
      } else if (date === undefined) {
        return undefined;
      } else {
        return null;
      }
    }
  }
};


})({});


(function(exports) {
var get = Ember.get, set = Ember.set, getPath = Ember.getPath;
DS.Model.reopenClass({
  typeForAssociation: function(name) {
    return Ember.get(this, 'associationsByName')[name];
  },

  associations: Ember.computed(function() {
    var map = Ember.Map.create();

    this.eachComputedProperty(function(name, meta) {
      if (meta.isAssociation) {
        var type = meta.type,
            typeList = map.get(type);

        if (typeof type === 'string') {
          type = getPath(this, type, false) || getPath(window, type);
        }

        if (!typeList) {
          typeList = [];
          map.set(type, typeList);
        }

        typeList.push({ name: name, kind: meta.kind });
      }
    });

    return map;
  }).cacheable(),

  associationsByName: Ember.computed(function() {
    var map = {}, type;

    this.eachComputedProperty(function(name, meta) {
      if (meta.isAssociation) {
        type = meta.type;

        if (typeof type === 'string') {
          type = getPath(this, type, false) || getPath(window, type);
        }

        map[name] = type;
      }
    });

    return map;
  }).cacheable()
});


var embeddedFindRecord = function(store, type, data, key, one) {
  var association = data ? get(data, key) : one ? null : [];
  if (one) {
    return association ? store.load(type, association).id : null;
  } else {
    return association ? store.loadMany(type, association).ids : [];
  }
};

var referencedFindRecord = function(store, type, data, key, one) {
  return data ? get(data, key) : one ? null : [];
};

var hasAssociation = function(type, options, one) {
  var embedded = options && options.embedded,
    findRecord = embedded ? embeddedFindRecord : referencedFindRecord;

  var meta = { type: type, isAssociation: true };
  if (one) {
    meta.kind = 'belongsTo';
  } else {
    meta.kind = 'hasMany';
  }

  return Ember.computed(function(key, value) {
    var data = get(this, 'data'), ids, id, association,
        store = get(this, 'store');

    if (typeof type === 'string') {
      type = getPath(this, type, false) || getPath(window, type);
    }

    key = (options && options.key) ? options.key : key;
    if (one) {
      id = findRecord(store, type, data, key, true);
      association = id ? store.find(type, id) : null;
    } else {
      ids = findRecord(store, type, data, key);
      association = store.findMany(type, ids);
      set(association, 'parentRecord', this);
    }

    return association;
  }).property('data').cacheable().meta(meta);
};

DS.hasMany = function(type, options) {
  ember_assert("The type passed to DS.hasMany must be defined", !!type);
  return hasAssociation(type, options);
};

DS.hasOne = function(type, options) {
  ember_assert("The type passed to DS.belongsTo must be defined", !!type);
  return hasAssociation(type, options, true);
};

DS.belongsTo = DS.hasOne;

})({});


(function(exports) {
})({});


(function(exports) {
//Copyright (C) 2011 by Living Social, Inc.

//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//of the Software, and to permit persons to whom the Software is furnished to do
//so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
})({});
