/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
  /**
   * Search Actions
   * @redux
   * @reduxActionScope LegacySearch
   */
export default {
     /**
      * Sets the router match information to the store.
      * @redux
      * @reduxActionCreator SET_ROUTER_MATCH
      * @param {Immutable.Map} match - the current route match information
     */
    // LEGACY ACTIONS 1.0
    autoComplete: params => async (dispatch, getState, api) => {
        dispatch({ type: 'autoCompleteRequest', params });
        let response = await api.searchAutoComplete(params);
        dispatch({ type: 'autoCompleteResponse', response });
    },

    categorySearch: params => (dispatch, getState, api) => {
        console.time('PERF-categorySearchRequest');
        dispatch({ type: 'categorySearchRequest', keyword: params });
        console.time('PERF-categorySearchRequest-ServerTime');
        return api.categorySearch({ keyword: params }).then(response => {
            console.timeEnd('PERF-categorySearchRequest-ServerTime');
            console.time('PERF-categorySearchResponseProcessing');
            dispatch({ type: 'categorySearchResponse', response: response });
            console.timeEnd('PERF-categorySearchResponseProcessing');
            console.timeEnd('PERF-categorySearchRequest');
        });
    },

    // contextResetDraft
    // contextClearFilter
    // contextClearDraftFilter
    // contextClearAllFilters
    // contextApplyDraftToContext
    // clearSearch

    search: params => (dispatch, getState, api) => {
        console.time('PERF-searchRequest');
        dispatch({ type: 'searchRequest', payload: params, clear: params.clear });
        console.time('PERF-searchRequest-ServerTime');
        return api.search({ requestJSON: JSON.stringify(params) }).then(response => {
            // Preformat attributes for Products
            console.timeEnd('PERF-searchRequest-ServerTime');
            console.time('PERF-searchRequestProcessing');
            let convertAttributesToArray = (item, idx) => {
                if (item.attributes) {
                    item.attributes = Object.keys(item.attributes).map(key => ({
                        name: key,
                        types: item.attributes[key]
                    }))
                }
                return item;
            };

            response.partnerResults = response.partnerResults.map(convertAttributesToArray);
            response.productResults = response.productResults.map(convertAttributesToArray);

            // DEBUG: Added to test no results state
            if (response.keyword === 'sr-test-no-results') {
                response.partnerResults = [];
                response.productResults = [];
            }

            dispatch({ type: 'searchResponse', response: response });
            console.timeEnd('PERF-searchRequestProcessing');
            console.timeEnd('PERF-searchRequest');
        });
    },

    // selectSearchCategory
    // toggleCategoryNode
    // togglePartnerFilterMobileNode

    selectGroupFilters: params => (dispatch, getState, api) => {
        let draft = params.draft || false;
        let newState =  { ...getState().search };
        let tagListId = params.filterId;
        let selectedTags = draft ? newState.selectedDraftFilters[tagListId] : newState.selectedFilters[tagListId];
        if (draft) {
            newState.selectedDraftFilters[tagListId] = params.selectedFilters;
            dispatch({
                type: 'toggleDraftContextFilter',
                selectedDraftFilters: newState.selectedDraftFilters
            });
        } else {
            newState.selectedFilters[tagListId] = params.selectedFilters;
            dispatch({
                type: 'toggleContextFilter',
                selectedFilters: newState.selectedFilters
            });
        }
    },

    toggleContextFilter: params => (dispatch, getState, api) => {
        let draft = params.draft || false;
        let newState =  { ...{modifiedFilters: {}} , ...getState().search };
        let selectedTags = draft ? newState.selectedDraftFilters[params.tagListId] : newState.selectedFilters[params.tagListId];
            selectedTags = selectedTags ? selectedTags : [];
        let tagSet = newState.filters.find(tag => tag.name === params.tagListId);
        newState.modifiedFilters  = newState.modifiedFilters ? newState.modifiedFilters : {};
        newState.modifiedFilters[tagSet.name] = true;
        let currentTagList;
        // get the actual tags list
        currentTagList = tagSet.tags ? tagSet.tags : [];
        // toggle the tag
        let arrayIndex = selectedTags.indexOf(params.id);

        let recursive = false,
            parent = false,
            recursiveSelect = true, //  ID-4309 - Decouple Rules Reference https://d.pr/i/6uE6Vp
            multilevel = tagSet.type === 'multilevel';

        let toggleTags = (arr, toggle, id) => {
            let arrIndex = arr.indexOf(id);
            if (toggle && arrIndex < 0){
                // add it to array
                arr.push(id);
            } else if (!toggle && arrIndex > -1) {
                // remove it from array
                arr.splice(arrIndex, 1);
            }
            return arr;
        };

        let recurseCheckboxTree = (boxes, recursedValue, level) => {
            boxes.forEach(checkbox => {
                let newRecursedValue = null;
                // If checkbox is matched here

                let multilevelLevel0 = (multilevel && level === 0);

                if (checkbox.value === params.id) {
                    // checkbox.checked = params.toggle;
                    // console.log('match', level, checkbox.value, multilevelLevel0);
                    toggleTags(selectedTags, params.toggle, checkbox.value);

                    // recursive - set children to parents value recursively
                    if (recursive) newRecursedValue = params.toggle;
                    // parent - uncheck children if parent is unchecked
                    if (parent && !params.toggle) newRecursedValue = false;
                    // multilevel rule if level 0 is checked you dont have to check the children

                    if (recursiveSelect && params.toggle) newRecursedValue = true;
                    if (recursiveSelect && !params.toggle) newRecursedValue = null;


                    // select only the parent not the children
                    // keep the children as it is don't touch it
                    if (multilevelLevel0 && params.toggle) newRecursedValue = null;

                    // unselect all children if parent is unselected
                    if (multilevelLevel0 && !params.toggle) newRecursedValue = false;

                } else if (recursedValue != null) { // null or undefined
                    // If this is Level 2 Below and the parent was the one selected
                    // check all checkboxes
                    // checkbox.checked = recursedValue;
                    toggleTags(selectedTags, recursedValue, checkbox.value);
                    // Copy the parent recursed value to the children of this
                    if (recursive || parent || multilevel) newRecursedValue = recursedValue;

                    if (recursiveSelect && params.toggle) newRecursedValue = params.toggle;
                }

                if (checkbox.children && checkbox.children.length) {
                    recurseCheckboxTree(checkbox.children, newRecursedValue, level + 1);

                    // if multilevel children shouldn't affect parent
                    // recursive - after recursing tree -- uncheck parents of any unchecked
                    if (!multilevelLevel0 && recursive) {
                        if (checkbox.children.find(child => selectedTags.indexOf(child.value) === -1)) {
                            // is checkbox children is inside the selected array if not return false
                            // return !c.checked;
                            //  checkbox.checked = false;
                            toggleTags(selectedTags, false, checkbox.value);
                        } else {
                            // checkbox.checked = true;
                            toggleTags(selectedTags, true, checkbox.value);
                        }
                    } else if (!multilevelLevel0 && parent) {
                        // parent - after recursing tree -- check parents of any checked
                        if (checkbox.children.find(child => selectedTags.indexOf(child.value) > -1)) {
                            // if any children are checked, check parent
                            //checkbox.checked = true;
                            toggleTags(selectedTags, true, checkbox.value);
                        }
                    }
                }
            });
            return boxes;
        };

        recurseCheckboxTree(currentTagList, null, 0);

        if (draft) {
            newState.selectedDraftFilters[params.tagListId] = selectedTags;
            dispatch({
                type: 'toggleDraftContextFilter',
                selectedDraftFilters: newState.selectedDraftFilters
            });
        } else {
            newState.selectedFilters[params.tagListId] = selectedTags;
            dispatch({
                type: 'toggleContextFilter',
                selectedFilters: newState.selectedFilters,
                modifiedFilters: newState.modifiedFilters
            });
        }
    },

    // toggleDisplayType

};