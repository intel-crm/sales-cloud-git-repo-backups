({
    getActions : function() {
        return {
            
            // +=+=+=+ SEARCH ACTIONS A-Z HERE +=+=+=+
            searchAutoComplete: function(params) { // renamed to "searchAutoComplete" from autoComplete by prabuddh
                return function(dispatch, getState, callServer) {
                    dispatch({ type: 'autoCompleteRequest', params: params });
                    return callServer('searchAutoComplete', params)
                    .then(function(response) {
                        dispatch({ type: 'autoCompleteResponse', response: response });
                    });
                };
            },
            
            categorySearch: function(params) {
                
                console.time('PERF-categorySearchRequest');
                return function(dispatch, getState, callServer) {
                    dispatch({ type: 'categorySearchRequest', keyword: params });
                    console.time('PERF-categorySearchRequest-ServerTime');
                    return callServer('categorySearch', { requestJSON: JSON.stringify(params) })// changed params to JSON.stringify(params) by prabuddh
                    .then(function(response) {
                        console.timeEnd('PERF-categorySearchRequest-ServerTime');
                        console.time('PERF-categorySearchResponseProcessing');    
                        dispatch({ type: 'categorySearchResponse', response: response });
                        console.timeEnd('PERF-categorySearchResponseProcessing');
                        console.timeEnd('PERF-categorySearchRequest');              
                    });
                };
            },
            
            contextResetDraft: function(params) {
                return function(dispatch, getState, callServer) {
                    var newState =  Object.assign({}, getState().Search);
                    
                    return dispatch(Object.assign({ type: 'contextResetDraft'}, params));
                };
            },
            //Added as part of Code Merge [10/16] - Clear All doesn't clear previously submitted items 
            //start 
            contextClearAllFilters: function(params) {
                return function(dispatch, getState, callServer) {
                    return dispatch(Object.assign({ type: 'contextClearAllFilters'}, params));
                };
            },
            //end 
            //
            
            clearExpandedCategories: function(params) {
                return function(dispatch, getState, callServer) {
                    return dispatch(Object.assign({ type: 'clearExpandedCategories'}));
                };
            },
            
            contextApplyDraftToContext: function(params) {
                return function(dispatch, getState, callServer) {
                    return dispatch(Object.assign({ type: 'contextApplyDraftToContext'}, params));
                };
            },
            
            clearSearch: function(params) {
                return function(dispatch, getState, callServer) {
                    return dispatch({ type: 'clearSearch' });
                };
            },
            
            search: function(params) {
                console.time('PERF-searchRequest');
                return function(dispatch, getState, callServer) {
                    dispatch({ type: 'searchRequest', payload: params });
                    console.time('PERF-searchRequest-ServerTime');
                    
                    return callServer('search', { requestJSON: JSON.stringify(params) })
                    .then(function(response) {
                        
                        // Preformat attributes for Products
                        console.timeEnd('PERF-searchRequest-ServerTime');
                        console.time('PERF-searchRequestProcessing');              
                        var convertAttributesToArray = function(item, idx) {
                            if (item.attributes) {
                                item.attributes = Object.keys(item.attributes).map(function(key) {
                                    return {
                                        name: key,
                                        types: item.attributes[key]
                                    };
                                });
                            }
                            return item;
                        };
                        
                        response.partnerResults = response.partnerResults.map(convertAttributesToArray);
                        response.productResults = response.productResults.map(convertAttributesToArray);
                        
                        // DEBUG: Added to test no results state
                        if (response.keyword == 'sr-test-no-results') {
                            response.partnerResults = [];
                            response.productResults = [];
                        }
                        
                        var ret = dispatch({ type: 'searchResponse', response: response });
                        console.timeEnd('PERF-searchRequestProcessing');
                        console.timeEnd('PERF-searchRequest');
                        return ret;
                    })
                };
            },
            
            selectSearchCategory: function(params) {
                return function(dispatch, getState, callServer) {
                    return dispatch(Object.assign({ type: 'selectSearchCategory' }, params));
                }
            },
            
            toggleCategoryNode: function(params) {
                return function(dispatch, getState, callServer) {
                    return dispatch(Object.assign({ type: 'toggleCategoryNode' }, params));
                }
            },
            
            togglePartnerFilterMobileNode: function(params) {
                return function(dispatch, getState, callServer) {
                    return dispatch(Object.assign({ type: 'togglePartnerFilterMobileNode' }, params));
                }
            },
            selectGroupFilters: function(params) {
                return function(dispatch, getState, callServer) {
                    
                    var draft = params.draft || false;
                    
                    var newState =  Object.assign({}, getState().Search);
                    var tagListId = params.filterId;
                    var selectedTags = draft ? newState.selectedDraftFilters[tagListId] : newState.selectedFilters[tagListId];
                    
                    // console.log('ISGActinoSearchController.selectGroupFilter Draft? oldTags? tagListId? selectedFilters',draft, selectedTags, tagListId, params.selectedFilters);
                    
                    if (draft) {
                        newState.selectedDraftFilters[tagListId] = params.selectedFilters;
                        
                        return dispatch(Object.assign({ type: 'toggleDraftContextFilter' }, {
                            selectedDraftFilters: newState.selectedDraftFilters
                        }));
                    } else {
                        newState.selectedFilters[tagListId] = params.selectedFilters;
                        
                        return dispatch(Object.assign({ type: 'toggleContextFilter' }, {
                            selectedFilters: newState.selectedFilters
                        }));
                    }
                }
            },
      toggleContextFilter: function(params) {
        return function(dispatch, getState, callServer) {
					var draft = params.draft || false;


					var newState =  Object.assign({}, getState().Search);
					var selectedTags = draft ? newState.selectedDraftFilters[params.tagListId] : newState.selectedFilters[params.tagListId];
							selectedTags = selectedTags ? selectedTags : [];
					var tagSet = newState.filters.find(function(tag) {
						return tag.name === params.tagListId;
          }), currentTagList;

					// get the actual tags list
					currentTagList = tagSet.tags ? tagSet.tags : [];
					// toggle the tag
					var arrayIndex = selectedTags.indexOf(params.id);
          
          var recursive = false,
              parent = false,
              recursiveSelect = true, //  ID-4309 - Decouple Rules Reference https://d.pr/i/6uE6Vp
              multilevel = tagSet.type == 'multilevel';

              var toggleTags = function(arr, toggle, id) {
						var arrayIndex = arr.indexOf(id);
						if (toggle && arrayIndex < 0){
							// add it to array
              arr.push(id);
						} else if (!toggle && arrayIndex > -1) {
							// remove it from array
              arr.splice(arrayIndex,1);
            }
						return arr;
          }

          var recurseCheckboxTree = function(boxes, recursedValue, level) {
            boxes.forEach(function(checkbox) {
              var newRecursedValue = null;
              // If checkbox is matched here

              var multilevelLevel0 = (multilevel && level == 0);

              if (checkbox.value == params.id) {
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
                  if (checkbox.children.find(function(c) { 
                        // is checkbox children is inside the selected array if not return false
                        // return !c.checked; 
                        return selectedTags.indexOf(c.value) == -1;
                    })
                    ) {
                    //  checkbox.checked = false;
                    toggleTags(selectedTags, false, checkbox.value);
                  } else {
                    // checkbox.checked = true;
                    toggleTags(selectedTags, true, checkbox.value);
                  }
                } else if (!multilevelLevel0 && parent) {
                // parent - after recursing tree -- check parents of any checked
                  if (checkbox.children.find(function(c) { 
                        // if any children are checked, check parent
                        // return c.checked; 
                        return selectedTags.indexOf(c.value) > -1;
                      })) {
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

	          return dispatch(Object.assign({ type: 'toggleDraftContextFilter' }, {
							selectedDraftFilters: newState.selectedDraftFilters
						}));
					} else {
						newState.selectedFilters[params.tagListId] = selectedTags;

	          return dispatch(Object.assign({ type: 'toggleContextFilter' }, {
							selectedFilters: newState.selectedFilters
						}));
					}
        }
      },
            
            
            
            toggleDisplayType: function(params) {
                return function(dispatch, getState, callServer) {
                    return dispatch(Object.assign({ type: 'toggleDisplayType' }, params));
                };
            },
            
            updateQuickSearchFilters: function(params){
                return function(dispatch, getState, callServer) {
                    return dispatch(Object.assign({ type: 'updateQuickSearchFilters', payload : params }));
                };
            }
            
        };
    }
    
})