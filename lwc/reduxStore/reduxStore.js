import { createStore, applyMiddleware, combineReducers } from './redux'; // ~28kb
import logger from './middleware/redux-logger'; // ~10kb
import thunk from './middleware/thunk'; // ~1kb
import { createCacher, restoreCache } from './middleware/cacher'; // ~1kb
import ReduxSubscriber from './middleware/subscriber'; // ~4kb
export { Store, Source } from './middleware/subscriber'; // for Jest tests

/*  ***** DO NOT MODIFY THIS FILE *****

NOTE:

This LWC component used Rollup.js to convert node modules to usable LWC minimized code:
Node Modules Used: 'redux', 'redux-persist', 'thunk', 'redux-persist-expire', 'redux-subscriber'
Total Size: ~ 45 kb

USAGE:

    Step 1: Create new Redux Store:
        const store = new ReduxStore(config);

    Config Options:
        debug - optional true/false logs Redux actions to console
        actions - required
        useStrictActions - optional true/false requires actions to be defined
        reducers - required
        api - optional api for thunk actions
        cache - true/false optional caching for store
        cacheKey - localStorage key for cached state
        cacheLife - optional 3600 (1 hour) default

    Step 2: Export the Store for other components to use:
        export default store;

    Step 3: Dispatch & Subscribe functions
        import { dispatch, subscribe } from 'c/myStore';
        dispatch('someActionName', payload);
        subscribe('some.state.path', result => { ... });
*/

class ReduxStore {
    constructor(config) {
        const defaultConfig = {
            debug: false,
            actions: {},
            useStrictActions: false,
            reducers: {},
            selectors: {},
            cache: false,
            cacheKey: 'c:ReduxStore:cache', // default
            cacheLife: 3600, // default 1 hour
            cacheReducers: {}
        };
        this.config = { ...defaultConfig, ...config };
        this._init(this.config);
        this._debouncedActions = {};
    }

    get state() {
        return this.store ? this.store.getState() : null;
    }

    get middlewareList() {
        return this._middleware;
    }

    _init(config) {
        // creates store
        let reducer, initialState, middleware = [];

        // injects api for thunk redux actions
        middleware.push(config.api ? thunk.withExtraArgument(config.api) : thunk);

        // adds localStorage caching middleware
        if (config.cache) {
            middleware.push(createCacher({
                key: config.cacheKey,
                life: config.cacheLife,
                reducer: combineReducers(config.cacheReducers)
            }));
        }

        // adds logger middleware
        if (config.debug) middleware.push(logger);

        this._middleware = middleware.map(m => m.name);

        // creates store
        reducer = typeof config.reducers === 'function' ? config.reducers : combineReducers(config.reducers);
        initialState = config.cache ? restoreCache(config.cacheKey) : {};
        this.store = createStore(reducer, initialState, applyMiddleware(...middleware));

        const reduxSubscriber = new ReduxSubscriber(this.store);

        // PUBLIC FUNCTIONS
        this.dispatch = this.dispatch.bind(this);
        this.subscribe = reduxSubscriber.subscribe.bind(reduxSubscriber);
        this.getState = this.store.getState;
        this.selectState = selector => config.selectors[selector](this.getState());
    }

    dispatch(actionType, params) {
        let action = this._getAction(actionType, params);
        return this.store.dispatch(action);
    }

    _getAction(actionType, params = {}) {
        let p = JSON.parse(JSON.stringify(params));
        let action = this.config.actions[actionType];
        if (this.config.useStrictActions && !action) {
            throw new TypeError(`Redux action: ${actionType} is not a registered action.`);
        }
        return (typeof action === 'function') ? action(p) : { ...p, type: actionType };
    }

}

export default ReduxStore;