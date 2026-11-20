({

  doInit: function(component, event, helper) {
    component.set('v.mapStateToAttributes', function(state) {
        var filtersList = state.filters || [];
      var selectedFilters = state.selectedFilters;
        
        var sortValue = '';
        if(state.searchType == 'product'){
            sortValue = 'Featured';
        }else if(state.searchType == 'partner'){
            sortValue = 'PartnertAscending';
        }
       
      return {
        searchLoading: state.searchLoading,
        searchString: state.searchString,
        searchType: state.searchType,
        sortField:sortValue  
      };
    });
      
    
  },

  handleDisplayList: function(component, event, helper) {
    helper.dispatch(component, 'toggleDisplayType', {
      displayType: 'list'
    });
  },

  handleDisplayCard: function(component, event, helper) {
    helper.dispatch(component, 'toggleDisplayType' , {
      displayType: 'card'
    });
  },

  handleSortBy: function(component, event, helper) {
      var currentState = component.get('v.state');
      console.log('State ==> ', currentState);
      var sortByField = document.getElementById("sortByField").value;
      
      var searchParams = {
      keyword: currentState.searchString,
      category: currentState.selectedCategoryId,
      specialty: currentState.selectedSpecId,   
      searchType: currentState.searchType,
      sortField : document.getElementById("sortByField").value,
     // sortField: currentState.sortByField
      sortDirection: 'DESC',
      selectedFilters: currentState.selectedFilters,
      currentPage: 1,
      pageSize: 9,
          langCode: $A.get("$Locale.langLocale")    
    };
  
      component.set('v.mapStateToAttributes', function(state) {
          return {
              sortField : document.getElementById("sortByField").value
          };
      });
      
   // console.log('SearchParams ==> ', searchParams);
   // console.log('SearchParams ==> sortField ==>', sortField);
    helper.dispatch(component, 'search', searchParams);
  },
    
   
})