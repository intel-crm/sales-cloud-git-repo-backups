const createCacher = cacheConfig => {
    const defaultConfig = {
        key: 'reduxCache',
        life: 3600, // 1 hour
        reducer: state => state
    };

    const config = { ...defaultConfig, ...cacheConfig };

    return function cacher(store) {
        return next => action => {
            const result = next(action);
            let storage = {
                _expires: Date.now() + (config.life * 1000),
                state: config.reducer(store.getState())
            };
            window.localStorage.setItem(config.key, JSON.stringify(storage));
            return result;
        }
    }
}

const restoreCache = cacheKey => {
    let storage = JSON.parse(window.localStorage.getItem(cacheKey));
    if (storage && Date.now() > storage._expires) {
        window.localStorage.removeItem(cacheKey);
        return {};
    } else if (storage) {
        return storage.state;
    }
    return {};
}

export { createCacher, restoreCache };