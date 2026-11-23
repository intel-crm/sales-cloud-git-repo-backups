({
    
    doInit : function(component, event, helper) { 
        console.log("searchResults");
        window.setTimeout($A.getCallback(function(){
            component.set('v.mapStateToAttributes', function(state) { //state will contain all the updated values and can be access in this function
           
            console.log('pageSize = '+state.pageSize+' currentPage'+state.currentPage+' searchResultsCount'+state.searchResultsCount);
            
           if(state.totalProductCount == 0 && state.totalPartnerCount >0)
                component.set('v.currentTab', '2');
            else
                component.set('v.currentTab','1'); 
            	            
            return {
                showPaging: (state.searchType != 'all' && state.searchResultsCount > state.pageSize),
                //showPaging: state.searchType != 'all',
                searchType: state.searchType,
                resultsPartners: state.resultsPartners,
                resultsProducts: state.resultsProducts,
               // resultsPartners: state.resultsPartners.slice(0, state.pageSize),
	           // resultsProducts: state.resultsProducts.slice(0, state.pageSize),
                searchLoading: state.searchLoading,
                rangeFirst: state.pageSize * (state.currentPage - 1) + 1,
                rangeLast: Math.min(state.pageSize * state.currentPage, state.searchResultsCount),
                currentPage: state.currentPage,
                totalPages: Math.ceil(state.searchResultsCount / state.pageSize),
                // BUG TODO Needs to be separated into Products/Partners for SEE ALL (N) Products link
                totalResults: state.searchResultsCount,
               // totalResultsPartners: state.resultsPartners.length,
               // totalResultsProducts: state.resultsProducts.length
                totalResultsPartners: state.totalPartnerCount,	//Added by Nikhil to fix See All Link count in homepage
                totalResultsProducts: state.totalProductCount   //Added by Nikhil to fix See All Link count in homepage
                //searchBoxPageName: state.searchBoxPageName
            };
        });
        }) );                                        
        

        component.set('v.onPageChange', function(currentPage) {
            helper.handlePageChange(component, helper, currentPage);
        });
        
        console.log('search results doInit');
       
    },
    
    handleSearchSuggestion: function(component, event, helper) {
        // helper
        //   .dispatch(component, 'search', {
        //     query: event.currentTarget.dataset.searchTerm
        //   })
        //   .then($A.getCallback(function() {
        //   }));
        event.preventDefault();
    },
    
    handleSelectAllProductCategory : function(component, event, helper) {
        helper.dispatch(component, 'selectSearchCategory', {
            categoryId: null,
            categoryType: 'product',
            categoryTitle: $A.get('$Label.c.PMP_All_Products'), // CUSTOM LABEL
            categoryDescription: '',
        });
        
        var userLangCode = $A.get("$Locale.langLocale"); // Defect Fix : DE62050 for Localization
        var currentState = component.get('v.state');
        var searchParams = {
            keyword: currentState.searchString,
            category: null,
            searchType: 'product',
            sortField: currentState.sortField,
            sortDirection: currentState.sortDirection,
            selectedFilters: currentState.selectedFilters,
            currentPage: currentState.currentPage,
            pageSize: currentState.pageSize,
	    langCode: userLangCode // Defect Fix : DE62050 - Adding langCode for localization on All products - Prabuddh 
        };
        
        helper.dispatch(component, 'search', searchParams);
	helper.dispatch(component, 'categorySearch', searchParams); // Defect Fix : DE62050 - Adding langCode for localization on All products - Prabuddh 
        window.scrollTo(0,300);
    },
    
    handleSelectAllPartnerCategory : function(component, event, helper) {
        helper.dispatch(component, 'selectSearchCategory', {
            categoryId: null,
            categoryType: 'partner',
            categoryTitle: $A.get('$Label.c.PMP_All_Partners'), // CUSTOM LABEL
            categoryDescription: '',
        });
        
	var userLangCode = $A.get("$Locale.langLocale"); // Defect Fix : DE62050 for Localization	    
        var currentState = component.get('v.state');
       
        var searchParams = {
            keyword: currentState.searchString,
            category: null,
            searchType: 'partner',
            sortField: currentState.sortField,
            sortDirection: currentState.sortDirection,
            selectedFilters: currentState.selectedFilters,
            currentPage: currentState.currentPage,
            pageSize: currentState.pageSize,
	    langCode: userLangCode // Defect Fix : DE62050 - Adding langCode for localization on All products - Prabuddh 		
        };
        
        helper.dispatch(component, 'search', searchParams);
	helper.dispatch(component, 'categorySearch', searchParams); // Defect Fix : DE62050 - Adding langCode for localization on All products - Prabuddh 	    
        window.scrollTo(0,300);
    },
    
    handleTabChange: function(component, event, helper) {
        component.set('v.currentTab', event.currentTarget.dataset.tabid);
    },
    
    triggerSearchAnalytics: function(component, event, helper){
       
        helper.sendSearchAnalyticsData(component, event, helper);
        
    },
    
  
    
})