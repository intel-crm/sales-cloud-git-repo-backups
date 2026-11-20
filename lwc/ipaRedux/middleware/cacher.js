const createCacher = cacheConfig => {
    const defaultConfig = {
        key: 'reduxCache',
        life: 3600, // 1 hour
        reducer: state => state,
        storage: 'localStorage'
    };

    const config = { ...defaultConfig, ...cacheConfig };

    return function cacher(store) {
        return next => action => {
            const result = next(action);
            if (config.storage === 'localStorage') {
                localStorage.setItem(config.key, JSON.stringify({
                    _expires: Date.now() + (config.life * 1000),
                    state: config.reducer(store.getState())
                }));
            } else if (config.storage === 'sessionStorage') {
                sessionStorage.setItem(config.key, JSON.stringify({
                    state: config.reducer(store.getState())
                }));
            }
            return result;
        }
    }
}

const restoreCache = (cacheKey, cacheStorage = 'localStorage') => {
    if (cacheStorage === 'localStorage') {
        let storage = JSON.parse(localStorage.getItem(cacheKey));
        if (storage && Date.now() > storage._expires) {
            window.localStorage.removeItem(cacheKey);
            return {};
        } else if (storage) {
            return storage.state;
        }
    } else if (cacheStorage === 'sessionStorage') {
        let storage = JSON.parse(sessionStorage.getItem(cacheKey));
        if (storage) return storage.state;
    }

    return {};
}

export { createCacher, restoreCache };