({
    
    getDefaultTypeAheadOptions : function(component) {
        
        var defaultTypeAheadOptions = [], keyword = component.get('v.searchQuery');
        
        // adds default options if given in design attributes (search bar full width)
        if (component.get('v.showSearchAllMarketplace')) {
            defaultTypeAheadOptions.push({
                category: null,
                keyword: keyword,
                label: component.get('v.searchAllMarketplaceLabel'),
                searchType: 'all',
                indent: true
            });
        }
        
        if (component.get('v.showSearchAllProducts')) {
            defaultTypeAheadOptions.push({
                category: null,
                keyword: keyword,
                label: component.get('v.searchAllProductsLabel'),
                searchType: 'product',
                indent: true
            });
        }
        
        if (component.get('v.showSearchAllPartners')) {
            defaultTypeAheadOptions.push({
                category: null,
                keyword: keyword,
                label: component.get('v.searchAllPartnersLabel'),
                searchType: 'partner',
                indent: true
            });
        }
        
        return defaultTypeAheadOptions;
    },
    
    getTypeaheadOptions : function(component, helper) {
        
        var searchString = component.get('v.searchQuery');
        //To capture type //Added By Manjula
        var searchType = component.get('v.searchType');    
        
        var searching = component.get('v.searchLoading');
        if (searchString.length > 2 && !searching) {
            
            /* // Commented by Subash for DE71727
            var isNew = searchString && (searchString != component.get('v._searchQuery'));
            if (isNew) {	
            */
            
            if(true) {
                // load type ahead data after 3 characters show type ahead options
                // Trigger Type Ahead
                var DELAY = 600; // debounce DELAY
                if (window._searchBarTypeAheadTimer) window.clearTimeout(window._searchBarTypeAheadTimer);
                window._searchBarTypeAheadTimer = window.setTimeout($A.getCallback(function() {
                    if (component.isValid()) {
                        
                        //changes for type-ahead defect // Added by Prabuddh
                        // component.set('v.typeAheadOptionsVisible',false);
                        //changes end
                        
                        // do not dispatch if search is triggered or loading already
                        if (!component.get('v.searchLoading')) {
                            component.set('v._searchQuery', searchString);
                            component.set('v.typeAheadOptionsVisible', true);
                            // helper.dispatch(component, 'autoComplete', { query: searchString });
                            // Capturing searchtype param to display typeahead values based on type // Added By Manjula
                            helper.dispatch(component, 'searchAutoComplete', { query: searchString, Type: searchType, langCode: $A.get("$Locale.langLocale")});
                            
                        }
                    }
                }), DELAY);
            }
            //Load type ahead values for the same characters//Added By Manjula
            else {
                component.set('v.typeAheadOptionsVisible', true);
            }
        } else {
            component.set('v.typeAheadOptionsVisible', false);
        }
    },
    
    performSearch: function(component, helper, searchType, category, query) {
        
        //debugger; // added by Uday
        component.set('v.typeAheadOptionsVisible', true);
        if (category && (category.id == "null")) category.id = null;
        if (component.get('v.refreshPageOnSearch')) {
            // build url params and go to new url
            //debugger; // added by Uday
            var urlParams = {
                cat: 		  category.id,
                q:        query,
                type:     searchType,
                p:		  component.get('v.page')	
            };
            var str = encodeURIComponent(JSON.stringify(urlParams)), pageName = 'search';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ url: '/' + pageName + '?search=' + str });
            if (component.get('v.debugMode')) {
                
            } else {
                urlEvent.fire();
            }
            
        } else {
            if (category) {
                //debugger; // added by Uday
                helper.dispatch(component, 'selectSearchCategory', {
                    categoryId: category.id,
                    categoryType: searchType,
                    categoryTitle: category.title,
                    categoryDescription: category.description,
                });
            }
            
            var currentState = component.get('v.state');
            var searchParams = {
                keyword: query,
                category: category ? category.id : currentState.selectedCategoryId,
                searchType: searchType,
                sortField: currentState.sortField,
                sortDirection: currentState.sortDirection,
                selectedFilters: currentState.selectedFilters,
                currentPage: 1,
                langCode: $A.get("$Locale.langLocale"),  
                pageSize: 9,   //Changed since 9 is the pagination limit //
                pageName: component.get('v.page')
            };
            //added by prabuddh     
            helper.dispatch(component, 'categorySearch', searchParams);
            //change ends
            helper.dispatch(component, 'search', searchParams);
            // helper.dispatch(component, 'searchAutoComplete', searchParams);
            
        }
    },
    
    getFocusedTypeaheadOption : function(component) {
        //debugger; // added by Uday
        var typeAheadItems = component.find('typeaheadOption') ?
            [].concat(component.find('typeaheadOption')) : [];
        return typeAheadItems.find(function(elem, index) {
            return elem.getElement() === document.activeElement;
        });
    },
    
    resetPlaceholder : function(component) {
        var label = 'Missing Custom Labels?', searchType = component.get('v.searchType');
        
        if (searchType == 'partner') {
            label = $A.get("$Label.c.PMP_Search_All_Partners");
            
        } else if (searchType == 'product') {
            //label = $A.get("$Label.c.PMP_Search_All_Products");
            label = $A.get("$Label.c.PMP_Search_For_Products");
            
            
        } else if (searchType == 'all') {
            label = $A.get("$Label.c.PMP_Search_All_Products_and_Partners");
        }
        
        // overrides w/ design attribute (for using on different pages L0, L1, etc.)
        if (component.get('v.searchPlaceholderTextOverride')) {
            label = component.get('v.searchPlaceholderTextOverride');
        }
        
        component.set('v.searchPlaceholderText', label);
    },
    
    navigateToRecord : function(component, recordId) {
        /*var urlEvent = $A.get("e.force:navigateToURL");  
    urlEvent.setParams({ 
        "url": '/' + "offering" + '/'+ recordId,
        "isredirect" :false
    });  
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": recordId,
      "slideDevName": "detail",
        "isredirect":true
    });*/
      
      var navEvt = $A.get("e.force:navigateToSObject");
      navEvt.setParams({
          "recordId": recordId
          //  "slideDevName": "detail",
          
      });
      
      navEvt.fire();
  },
    
    setPageName : function(component){
        var windowUrl = window.location.href;
        
        if(windowUrl.includes("search") || windowUrl.includes("pmp-category") || windowUrl.includes("pmp-specification") || windowUrl.includes("pmp-partner-program") || windowUrl.includes("pmp-partner-specialty")){
            component.set('v.page', 'search');
        }else{
            component.set('v.page', 'home');
        }
    }	
    
})