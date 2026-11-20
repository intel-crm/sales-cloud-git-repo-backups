class Subscription {
    constructor(source, key) {
        this._source = source;
        this._key = key;
    }

    unsubscribe() {
        this._source.unsubscribe(this._key);
    }
}

export class Source {
    constructor(initialValue) {
        this._subscriptions = {};
        this._currentSubscribersKey = 0;
        this._currentValue = initialValue;
    }

    get subscriptions() {
        return Object.keys(this._subscriptions).length;
    }

    get value() {
        return this._currentValue;
    }

    subscribe(reader, silent = false) {
        if (typeof reader === 'function' && !silent) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => reader(this._currentValue));
        }
        this._currentSubscribersKey++;
        this._subscriptions[this._currentSubscribersKey] = reader;
        return new Subscription(this, this._currentSubscribersKey);
    }

    unsubscribe(subscriptionKey) {
        delete this._subscriptions[subscriptionKey];
    }

    publish(value, skipSavingValue = false) {
        let currentValue = Object.freeze(value);
        if (!skipSavingValue) this._currentValue = currentValue;
        for (let reader of Object.values(this._subscriptions)) {
            if (typeof reader === 'function') {
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => reader(currentValue));
            }
        }
    }
}

export class Store {
    constructor() {
        this._sources = {};
    }

    get sources() {
        return Object.keys(this._sources);
    }

    addSource(key, initialValue) {
        this._sources[key] = this._sources[key] || new Source(initialValue || null);
    }

    hasSource(key) {
        if (!this._sources[key]) {
            throw new TypeError(`DataSource does not contain key: ${key}`);
        } else { return true; }
    }

    updateSource(key, value, skipSavingValue = false) {
        if (this.hasSource(key)) this._sources[key].publish(value, skipSavingValue);
    }

    subscribeToSource(key, reader, silent) {
        if (this.hasSource(key)) {
            return this._sources[key].subscribe(reader, silent);
        } return {};
    }

    removeSource(key) {
        if (this._sources[key] && this._sources[key].subscriptions === 0) {
            delete this._sources[key];
        }
    }
}

// if no keyPath is given, subscribe to the entire app state
const appStateSubscriptionKey = '__APPSTATE__';
const traverse = (obj, key) => {
    if (key === appStateSubscriptionKey) return obj;
    try {
        return key.split('.').reduce((o, i) => o[i], obj);
    } catch(err) {
        // eslint-disable-next-line no-console
        console.error('Current Redux State: ', obj);
        throw new TypeError(
            `Redux subscriber error! Failed attempting to traverse store state: ${key}`
        );
    }
};

class ReduxSubscriber {
    constructor(reduxStore) {
        this.reduxStore = reduxStore;
        this.prevState = this.reduxStore.getState();
        this.reduxStore.subscribe(() => {
            const nextState = this.reduxStore.getState();
            this._notifySubscribers(this.prevState, nextState);
            this.prevState = nextState;
        });
        this.store = new Store();
    }

    subscribe(keyPath, reader, silent) {
        let key, readerFn;
        if (typeof keyPath === 'function') {
            key = appStateSubscriptionKey;
            readerFn = keyPath;
        } else if (typeof keyPath === 'string' && typeof reader === 'function') {
            key = keyPath;
            readerFn = reader;
        } else {
            throw new TypeError('A callback function must be provided to subscribe to the store.');
        }

        this.store.addSource(key);
        let subscription = this.store.subscribeToSource(key, readerFn, true);
        let subscribed = true;

        // pass current value on subscribe
        if (!silent) readerFn(traverse(this.prevState, key));

        // return unsubscribe function
        return () => {
            if (subscribed) {
                subscription.unsubscribe(); // unsubscribes
                this.store.removeSource(key); // removes source if possible
                subscribed = false;
            }
        };
    }

    // notify subscribers only if state (or partial state) has changed
    _notifySubscribers(prevState, nextState) {
        this.store.sources.forEach(source => {
            if (traverse(prevState, source) !== traverse(nextState, source)) {
                this.store.updateSource(source, traverse(nextState, source), true);
            }
        });
    }
}

export default ReduxSubscriber;