({

	doInit : function(component, event, helper) {
       
		component.set('v.mapStateToAttributes', function(state) {
            
			return {
				urlParams: state.urlParams
			};
		});

    // INITIAL SEARCH PERFORMED ON PAGE LOAD
    var defaultSearchParams = {
      keyword: '',
      category: null,
      searchType: 'all',
      sortField:'' ,
      sortDirection: 'DESC',
      selectedFilters: {},
      currentPage: 1,
      pageSize: 9,   //component.get('v.defaultPageSize')  commented by Nikhil as it is taking 6 by default but should be 9
      langCode: $A.get("$Locale.langLocale") 	
    };

		var urlParams = helper.getUrlParams(component, helper);
		var searchParams = Object.assign(defaultSearchParams, urlParams);
        if(component.get('v.hasSelectedFilter')){
            helper.getSelectedFilters(component,component.get('v.contextualCat')).then($A.getCallback(function(){                   
            searchParams.selectedFilters = component.get('v.selectedFilters');
            helper.dispatch(component, 'search', searchParams);
            console.log('SearchParams before catSearch 1: ', searchParams);
            helper.dispatch(component, 'categorySearch', searchParams) //searchParams.keyword changed to searchParams : Prabuddh 
            .then(function(state) {          
                if (state.Search.searchType != 'all') {
                    var categories = state.Search.categories.partnerCategories
                    .concat(state.Search.categories.productCategories).concat(state.Search.categories.productCategories[4].children); // Added solution's children categories for Featured Carousel - Prabuddh
                    var matchingCategory = categories.find(function(cat) {
                        return cat.categoryId == searchParams.category;
                    });
                    
                    
                    
                    var categoryTitle = matchingCategory ? matchingCategory.categoryName : null;            
                    var categoryDescription = matchingCategory ? matchingCategory.categoryDescription : null;
                    var categoryCtaLink =   matchingCategory ? matchingCategory.categoryCtaLink : null
                    helper.dispatch(component, 'selectSearchCategory', {
                        categoryId:               searchParams.category,
                        categoryType:             searchParams.searchType,
                        categoryTitle:            categoryTitle,
                        categoryDescription:      categoryDescription,
                        categoryCtaLink: 		  categoryCtaLink  
                    });
                }
            }); 
        }));
        }else{
            helper.dispatch(component, 'search', searchParams);
            console.log('SearchParams before catSearch : ', searchParams);
            helper.dispatch(component, 'categorySearch', searchParams) //searchParams.keyword changed to searchParams : Prabuddh 
            .then(function(state) {          
                if (state.Search.searchType != 'all') {
                    var categories = state.Search.categories.partnerCategories
                    .concat(state.Search.categories.productCategories).concat(state.Search.categories.productCategories[4].children); // Added solution's children categories for Featured Carousel - Prabuddh
                    var matchingCategory = categories.find(function(cat) {
                        return cat.categoryId == searchParams.category;
                    });
                    
                    
                    
                    var categoryTitle = matchingCategory ? matchingCategory.categoryName : null;            
                    var categoryDescription = matchingCategory ? matchingCategory.categoryDescription : null;
                    var categoryCtaLink =   matchingCategory ? matchingCategory.categoryCtaLink : null
                    helper.dispatch(component, 'selectSearchCategory', {
                        categoryId:               searchParams.category,
                        categoryType:             searchParams.searchType,
                        categoryTitle:            categoryTitle,
                        categoryDescription:      categoryDescription,
                        categoryCtaLink: 		  categoryCtaLink  
                    });
                }
            });
        }
        
	},

	handleChangeUrlParams : function(component, event, helper) {
		// var urlParams = component.get('v.urlParams');
    // var str = encodeURIComponent(JSON.stringify(urlParams));
    // str = '?search=' + str;
    // console.info('Current Search params (add to pushstate history?) ' + str);

		// TODO...
		// window.history.pushState({ search: urlParams }, null, str);
	}

})