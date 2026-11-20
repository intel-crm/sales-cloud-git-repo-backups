/* SOURCE: https://github.com/reduxjs/redux-thunk/blob/master/src/index.js */

function createThunkMiddleware(extraArgument) {
    return function thunk({ dispatch, getState }) {
        return next => action => {
            if (typeof action === 'function') {
                const myDispatch = (myAction, params = {}) => {
                    if (typeof myAction === 'string') {
                        return dispatch({ type: myAction, ...params });
                    }
                    return dispatch(myAction);
                };
                return action(myDispatch, getState, extraArgument);
            }

            return next(action);
        }
    };
}

const thunk = createThunkMiddleware();
thunk.withExtraArgument = createThunkMiddleware;

export default thunk;