({
    
  /*  getCacheFormatter: function() {
        return function(state) {
            return Object.assign({}, state, {
                categories: Object.assign({}, state.categories, {
                    partnerCategories: [],
                    productCategories: []
                }),
                resultsPartners: [],
                resultsProducts: [],
                filtersModified: {},
            });
        };
    },*/
    getReducer: function() {
        return function(state, action) {
            
            // Initial State
            if (!state) state = {
                urlParams: '',
                shareUrl: '',
                searchType: 'all', // 'all', 'product', 'partner'
                selectedCategoryId: null,
                selectedSpecId:null,
                categories: {
                    allMarketplaceCount: 0,
                    allProductCount: 0,
                    allPartnerCount: 0,
                    partnerCategories: [],
                    productCategories: [],
                    expanded: ['all', 'product', 'partner'],
                    breadcrumbs: []
                },
                currentPage: 1,
                pageSize: 9,
                searchResultsCount: 0,
                sortByField: '',
                sortDirection: '',
                searchHeading: '',
                searchSubHeading: '',
                searchCtaLink: '',
                listDisplayType: 'card',
                searchString: '',
                resultsPartners: [],
                resultsProducts: [],
                searchTypeAheadOptions:[],
                filters: [],
                filtersModified: {},
                selectedFilters: {},
                filterTagListId: '', // Added by MGDANIES - 10/24
                selectedDraftFilters: {},
                partnerFiltersExpanded: [],
                showMapButton: false,
                searchLoading: false,
                userLangCode: '',
                searchBoxPageName: 'home',
                isQsearch: false,
                quickSearchFilters: [],
                responseSet: false,
                isSearchCleared: false,
                isCategoryNodeClicked:false
                //areFiltersLoaded:false
                
            };
            
            switch(action.type) {
                    
                    
                case 'categorySearchRequest':
                    return Object.assign({}, state, {
                        searchLoading: true,
                        searchString: action.keyword.keyword,
                        userLangCode: action.keyword.langCode,
                       // resultsPartners: [],
                       // resultsProducts: []
                    });
                    
                case 'categorySearchResponse':
                    var filters = action.response.filters || [];
                    // Added by MGDANIES - 10/24
                    // Check if the user clicked on a filter - filterTagListId is the ID of the top level filter
                    if (state.filterTagListId && filters.length && state.filters && state.filters.length) {
                        // Yes so create function for getting the current filter in the array
                        var getFilterIndex = function(filter) {
                            return filter.name === state.filterTagListId;  
                        };
                        // Get the indexes for the current filter in the repsonse from the server and the current state filters
                        var responseIndex = filters.findIndex(getFilterIndex);
                        var stateIndex = state.filters.findIndex(getFilterIndex);
                        
                        // Check that both indexes were found
                        if (responseIndex >= 0 && stateIndex >= 0) {
                            // Replace the corresponding response filter with the current state filter
                            // Added if to check if any filter is selected
                            if(state.selectedFilters[state.filterTagListId].length > 0) 
                                filters[responseIndex] = state.filters[stateIndex];
                        }
                    }
                    console.log('FIlters updated : ', JSON.stringify(filters));
                    return Object.assign({}, state, {
                        searchLoading: false,
                        areFiltersLoaded:true,
                        categories: {
                            allMarketplaceCount: action.response.allMarketplaceCount,
                            allProductCount: action.response.allProductCount,
                            allPartnerCount: action.response.allPartnerCount,
                            partnerCategories: action.response.partnerCategories,
                            productCategories: action.response.productCategories,
                            breadcrumbs: state.categories.breadcrumbs,
                            expanded: state.categories.expanded  // MGDANIES - 10/31 Changed to the current state so that categories are not collapsed when clicked on
                        },
                        filters: filters,
                        filterTagListId: action.response.tagListId
                        
                    });
                    
                case 'contextClearAllFilters':
                    var clearedFilter = Object.assign({}, state.selectedFilters);
                    Object.keys(clearedFilter).forEach(function(key){
                        clearedFilter[key] = [];
                    })
                    
                    return Object.assign({}, state, {
                        selectedFilters: clearedFilter,
                        filterTagListId: ''
                    });      
                    
                case 'contextApplyDraftToContext':
                    return Object.assign({}, state, {
                        selectedFilters: JSON.parse(JSON.stringify(state.selectedDraftFilters))
                    });
                    
                case 'contextResetDraft':
                    return Object.assign({}, state, {
                        selectedDraftFilters: JSON.parse(JSON.stringify(state.selectedFilters))
                    });
                    
                case 'searchRequest':
                    // This structure must match the SearchParams component
                    // and is designed to be a short as possible for a minimum URL length
                    var urlParams = {
                        cat: action.payload.category,
                        q: action.payload.keyword,
                        page: action.payload.currentPage,
                        type: action.payload.searchType,
                        dir: action.payload.sortDirection,
                        field: action.payload.sortField,
                        selectedFilters: action.payload.selectedFilters,
                        langCode: action.payload.langCode
                    };
                    /* if(window.location.href.indexOf("pmp-category") > -1){
                    //var seourl = window.location.href;
                    //console.log('----seo url----'+seourl);
                    //alert('entering if block for category');
					//var urlString = window.location.origin + window.location.pathname.substring(window.location.pathname.indexOf('/', 0), window.location.pathname.indexOf('/', 5));
					//var urlString = window.location.href;
                    //+ window.location.pathname.substring(window.location.pathname.indexOf('/', 0), window.location.pathname.indexOf('/', 5));                    
                    var urlString = window.location.origin + window.location.pathname;
                    var paramString = window.location.href.split('?')[1] || '';
                    try {
                        var params = paramString.split('&');
                        var origParams = {}, newParams = [];
                        params.forEach(function(p) {
                            origParams[p.split('=')[0]] = decodeURIComponent(p.split('=')[1] || '');
                        });
                        origParams.search = JSON.stringify(urlParams);
                        Object.keys(origParams).forEach(function(p) {
                            newParams.push(p + '=' + encodeURIComponent(origParams[p]));
                        });
                        urlString = urlString + '?' + newParams.join('&'); 
                       //urlString = window.location.origin + window.location.pathname+'?' + newParams.join('&');
    

                        //For SEO url appending the existing url 
                        
                    } catch(e) {
                        console.error('Search Params incorrect JSON format.', e);
                    }
                        
                    }
                    else{ */
                    //alert('entering else block for normal search');
                    var urlString = window.location.origin + window.location.pathname;
                    var paramString = window.location.href.split('?')[1] || '';
                    try {
                        var params = paramString.split('&');
                        var origParams = {}, newParams = [];
                        params.forEach(function(p) {
                            origParams[p.split('=')[0]] = decodeURIComponent(p.split('=')[1] || '');
                        });
                        origParams.search = JSON.stringify(urlParams);
                        Object.keys(origParams).forEach(function(p) {
                            newParams.push(p + '=' + encodeURIComponent(origParams[p]));
                        });
                        urlString = urlString + '?' + newParams.join('&');    
                        //For SEO url appending the existing url 
                    } catch(e) {
                        console.error('Search Params incorrect JSON format.', e);
                    }
                    // }
                    var filtersModified = {}, selectedFilters = action.payload.selectedFilters;
                    Object.keys(selectedFilters).forEach(function(filter) {
                        if (selectedFilters[filter] && selectedFilters[filter].length) {
                            filtersModified[filter] = true;
                        }
                    });		console.log('search box page : ', action.payload.pageName);
                    return Object.assign({}, state, {
                        urlParams: urlParams,
                        shareUrl: urlString,
                        searchLoading: true,
                        // update state to reflect current search
                        searchString: action.payload.keyword,
                        selectedCategoryId: action.payload.category,
                        selectedSpecId:action.payload.specialty,
                        selectedFilters: action.payload.selectedFilters,
                        currentPage: action.payload.currentPage,
                        searchType: action.payload.searchType,
                        sortDirection: action.payload.sortDirection,
                        sortField: action.payload.sortField,
                        langCode: action.payload.langCode,
                        searchBoxPageName: action.payload.pageName,
                        isQsearch: action.payload.isQsearch,
                        isSearchCleared: action.payload.isSearchCleared,
                        isCategoryNodeClicked: action.payload.isCategoryNodeClicked
                        
                    });
                
                case 'updateQuickSearchFilters':
                    return Object.assign({}, state, {
                        quickSearchFilters: action.payload.quickSearchFilters                        
                    });
                    
                /*case 'updateFilters':
                    var filters = action.payload.recentFilters || [];
                    
                    var currentFilter = JSON.parse(sessionStorage.getItem('currentFilter'));
                    if(currentFilter!=null){
                       currentFilter.autoexpand = null; 
                    }
                    
                    console.log('currentFilter : ', currentFilter);
                    // Added by MGDANIES - 10/24
                    // Check if the user clicked on a filter - filterTagListId is the ID of the top level filter
                    if (action.payload.filterId && filters.length && action.payload.prevFilters && action.payload.prevFilters.length) {
                        // Yes so create function for getting the current filter in the array
                        var getFilterIndex = function(filter) {
                            return filter.name === currentFilter.name;  
                        };
                        // Get the indexes for the current filter in the repsonse from the server and the current state filters
                        var responseIndex = filters.findIndex(getFilterIndex);
                        var stateIndex = action.payload.prevFilters.findIndex(getFilterIndex);
                        
                        // Check that both indexes were found
                        if (responseIndex >= 0 && stateIndex >= 0) {
                            // Replace the corresponding response filter with the current state filter
                            // Added if to check if any filter is selected
                            if(state.selectedFilters[action.payload.filterId].length > 0) 
                                filters[responseIndex] = currentFilter;
                        }
                    }
                    console.log('Filters final : ', filters);
                    return Object.assign({}, state,{
                        filters : filters
                    });*/
                    
                case 'searchResponse':
                    console.log('response : ', state.searchBoxPageName);
                    var selectedFilters = Object.assign({}, state.selectedFilters);
                    if (action.response.filters) {
                        action.response.filters.forEach(function(item) {
                            if (item.type === 'tag' && !selectedFilters[item.name]) {
                                selectedFilters[item.name] = [];
                            }
                            return '';
                        });
                        var regionFilter = action.response.filters.find(function(f) { return f.name === 'region'; });
                        // if (regionFilter && !state.filtersModified.region) {
                        
                        //   var recurseTree = function(tags) {
                        //     if (!tags || !tags.length) return [];
                        //     return tags.reduce(function(values, tag) {
                        //       return values.concat(tag.value, recurseTree(tag.children));
                        //     }, []);
                        //   };
                        //   var allRegions = recurseTree(regionFilter.tags);
                        //   selectedFilters.region = allRegions;
                        //   // example:
                        //   if (state.language == 'ja') selectedFilters.region = ['ja'];
                        // }
                    }
                    
                    
                    return Object.assign({}, state, {
                        searchLoading: false,
                        searchHeading: action.response.searchHeading,
                        searchSubHeading: action.response.categoryDescription,
                        resultsPartners: action.response.partnerResults,
                        resultsProducts: action.response.productResults,
                        searchResultsCount: action.response.totalCount,
                        selectedFilters: selectedFilters,
                        totalProductCount: action.response.totalProductCount,   //Added by Nikhil to fix See All Link count in homepage
                        totalPartnerCount: action.response.totalPartnerCount,    //Added by Nikhil to fix See All Link count in homepage
                        
                    });
                
                case 'clearSearch':
                    return Object.assign({}, state, { searchString: '', resultsPartners: [], resultsProducts: [] });
                    
                    // Added by MGDANIES - 10/31
                case 'clearExpandedCategories':
                    var newState = Object.assign({}, state);
                    newState.categories.expanded = ['all', 'product', 'partner'];
                    return newState;
                    
                case 'autoCompleteRequest':
                    return Object.assign({}, state, { searchTypeAheadOptions: [] });
                    
                case 'autoCompleteResponse':
                    return Object.assign({}, state, { searchTypeAheadOptions: action.response });
                    
                case 'selectSearchCategory':
                    var newState = Object.assign({}, state, {
                        selectedCategoryId: action.categoryId,
                        searchType:         action.categoryType,
                        searchCtaLink:      action.categoryCtaLink,
                        filterTagListId: '' // Added by MGDANIES - 10/24
                    });
                    
                    var expanded = ["all"], listToSearch = [], foundParents = [];
                    if (action.categoryType == 'all') {
                        expanded.push("partner", "product");
                    } else {
                        expanded.push(action.categoryType);
                    }
                    // recursively find parent categories
                    
                    var searchThroughTree = function(categories, id, parentHistory) {
                        return categories.reduce(function(nodes, cat) {
                            if (cat.categoryId == id) {
                                return nodes.concat(cat);
                            } else if (cat.children && cat.children.length) {
                                var childCat = null;
                                if (childCat = cat.children.find(function(c) { return c.categoryId == id; })) {
                                    parentHistory = parentHistory || [];
                                    return nodes.concat(parentHistory).concat(cat).concat(childCat);
                                } else {
                                    var parent = parentHistory || [];
                                    parent = parent.concat(cat);
                                    return nodes.concat(searchThroughTree(cat.children, id, parent));
                                }
                            } else { return nodes; }
                        }, []);
                    }
                    if (action.categoryId) {
                        if (action.categoryType == 'partner') listToSearch = state.categories.partnerCategories;
                        if (action.categoryType == 'product') listToSearch = state.categories.productCategories;
                        foundParents = searchThroughTree(listToSearch, action.categoryId);
                        expanded = expanded.concat(foundParents.map(function(x) {
                            return x.categoryId;
                        })).concat(action.categoryId);
                        
                    }
                    newState.categories.breadcrumbs = foundParents;
                    newState.categories.expanded = expanded;
                    return newState;
                    
                case 'toggleContextFilter':
                    /*return Object.assign({}, state, {
    selectedFilters: action.selectedFilters,
    filtersModified: Object.assign({}, state.filtersModified, { [action.id]: true })
  });*/
                    return Object.assign({}, state, { selectedFilters: action.selectedFilters, filterTagListId: action.tagListId });
                    
                case 'toggleDraftContextFilter':
                    // Added filterTagListId by MGDANIES - 10/24
                    return Object.assign({}, state, { selectedDraftFilters: action.selectedDraftFilters, filterTagListId: action.tagListId });
                    
                case 'toggleDisplayType':
                    return Object.assign({}, state, { listDisplayType: action.displayType });
                    
                case 'togglePartnerFilterMobileNode':
                    var newState = Object.assign({}, state);
                    var index = state.partnerFiltersExpanded.indexOf(action.value);
                    if (index > -1) {
                        newState.partnerFiltersExpanded = newState.partnerFiltersExpanded.slice(0, index);
                    } else if (index == -1) {
                        newState.partnerFiltersExpanded.push(action.value);
                    }
                    return newState;
                    
                case 'toggleCategoryNode':
                    var newState = Object.assign({}, state);
                    var index = state.categories.expanded.indexOf(action.value);
                    if (index > -1) {
                        newState.categories.expanded = newState.categories.expanded.slice(0, index);
                    } else if (index == -1) {
                        newState.categories.expanded.push(action.value);
                    }
                    return newState;
                    
                default:
                    return state;
            }
        };
    },
    
    
})