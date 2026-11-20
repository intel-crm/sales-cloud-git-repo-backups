// /* Redux Store Example */

// import actions from './actions';
// import reducers from './reducers';
// import ReduxStore from 'c/reduxStore';
// import auraApi from 'c/customAuraApi';

// /* Settings */
// // checks to see if in the community builder
// const DEBUG = window.location.href.match('commeditor') != null;

// /* Redux Store Config */
// const config = {
//     debug: DEBUG,

//     actions,
//     reducers,

//     api: auraApi,

//     cache: ['settings'], // optional whitelist of state for caching (default none)
//     cacheExpires: 3600, // optional (default 3600 -- 1 hour)
// };

// // export ReduxStore object
// // this object has { dispatch, subscribe } functions
// const store = new ReduxStore(config);
// export default store;