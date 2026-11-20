({
    
    handlePageChange: function(component, helper, currentPage) {
        var currentState = component.get('v.state');
        var userLangCode = $A.get("$Locale.langLocale");
        var searchParams = {
            keyword: currentState.searchString,
            category: currentState.selectedCategoryId,
            searchType: currentState.searchType,
            sortField: currentState.sortField,
            sortDirection: currentState.sortDirection,
            selectedFilters: currentState.selectedFilters,
            currentPage: currentPage,
            pageSize: currentState.pageSize,
            langCode: userLangCode //Adding langCode for localization on pagination - Prabuddh
        };
        
        helper.dispatch(component, 'search', searchParams);
        window.scrollTo(0,300);
    },
    
    sendSearchAnalyticsData: function(component, event, helper){
        //Fetching app state slice for the store "Search"
        var currentState = component.get('v.state');
        var analyticsData = component.find("analyticsData");   
        
        console.log('Category testing : ', currentState.selectedCategoryId);
        
        if(currentState.searchBoxPageName == 'home'){
            var type = 'search';
            var element = 'search';
            var detail = currentState.searchResultsCount + '|'+ currentState.searchString;
            analyticsData.formAnalyticsData(type,detail,element);
        }else if(currentState.searchBoxPageName == 'search' || currentState.isSearchCleared){
            
            if(currentState.selectedCategoryId==null){
                var type = 'filter';
                var element = 'search-offerings-filter';
                var detail = currentState.searchResultsCount + '|'+ ((currentState.searchString=='')?'no keyword':currentState.searchString);
                analyticsData.formAnalyticsData(type,detail,element);
            }else{
                var type = 'filter';
                var element = 'search-offerings-filter';
                var detail = currentState.searchResultsCount + '|'+ ((currentState.searchString=='')?'no keyword':currentState.searchString) + '|' + currentState.selectedCategoryId;
                analyticsData.formAnalyticsData(type,detail,element);
            }
            
            
        }
            else if(currentState.isQsearch){            
                var type = 'filter';
                var element = 'quick-search-filter';
                var detail = currentState.searchResultsCount + '|'+ analyticsData.formQuickSearchDetail(currentState.quickSearchFilters, currentState.selectedFilters, 'filter');
                analyticsData.formAnalyticsData(type,detail,element);
            }
                else if(currentState.isCategoryNodeClicked){
                    
                    //if(currentState.selectedCategoryId != null){
                        var type = 'filter';
                        var element = 'search-panel-filter';
                        var detail = currentState.searchResultsCount + '|'+ ((currentState.searchString=='')?'no keyword':currentState.searchString) + '|' + currentState.selectedCategoryId;
                        analyticsData.formAnalyticsData(type,detail,element);
                    //}
                }
        
        
    },
    
})