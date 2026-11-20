export const logger = store => next => action => {
    console.log('%c' + action.type, 'color: #005A9D; font-weight: bold;', 'ipaRedux Action', action);
    console.log('%cPrevious State:', 'color: #00AEEF; font-weight: bold;', store.getState());
    let result = next(action);
    console.log('%cNext State:', 'color: #0071C5; font-weight: bold;', store.getState());
    return result;
}

export const crashReporter = store => next => action => {
    try {
        return next(action);
    } catch (err) {
        console.error('ipaRedux: Caught an exception!')
        console.log('ipaRedux Error: ', err, action, store.getState());
        throw err;
    }
}