({
    
    // NOTE: Initial Search for L2 page is dispatched from ISGSearchParams component
    
    doInit : function(component, event, helper) {
        
        //Setting the page name in which the search bar is
        helper.setPageName(component);
        
        component.set('v.mapStateToAttributes', function(state) {
            /*commented below code to make default typeahead options visible when there is no results */   
            /* var defaultOptions = state.searchTypeAheadOptions.length > 0 ?
        helper.getDefaultTypeAheadOptions(component) : [];*/
            var defaultOptions = helper.getDefaultTypeAheadOptions(component);
            
            return {
                typeAheadOptions: defaultOptions.concat(state.searchTypeAheadOptions),
                searchString: state.searchString,
                searchLoading: state.searchLoading
            };
        });
        
        component.set('v.handleClose', $A.getCallback(function() {
            setTimeout($A.getCallback(function() {
                var selected = helper.getFocusedTypeaheadOption(component);
                if (!selected) component.set('v.typeAheadOptionsVisible', false);
            }), 80);
        }));
        
        helper.resetPlaceholder(component);
    },
    
    handleSearch: function(component, event, helper) {
        helper.setPageName(component);
        
        var category = {
            id: component.get('v.state.selectedCategoryId'),
            title: component.get('v.state.selectedCategoryTitle'),
            description: component.get('v.state.selectedCategoryDescription')
        }
        var searchType = event.currentTarget.dataset.searchtype;
        
        helper.performSearch(component, helper, searchType, category, component.get('v.searchQuery'));
        if(component.get('v.page') == 'home'){
            //Analytics code for search
            var analyticsData = component.find("analyticsData");
            var type = 'search';
            var element = 'search';
            var detail = 'search-box: text|'+component.get('v.searchQuery');
            analyticsData.formAnalyticsData(type,detail,element);
            //Analytics code end
        }
    },
    
    handleClose : function(component, event, helper) {
        setTimeout($A.getCallback(function() {
            var selected = helper.getFocusedTypeaheadOption(component);
            if (!selected) component.set('v.typeAheadOptionsVisible', false);
        }), 40);
    },
    
    handleKeyUp: function(component, event, helper) {
        helper.getTypeaheadOptions(component, helper);
        event.preventDefault();
    },
    
    handleKeyDown: function(component, event, helper) {
        helper.setPageName(component);
        //console.log('page name : ' , component.get('v.page'));
        var keyPress = event.which;
        //debugger; // added by Uday
        if (keyPress == 40 || keyPress == 38){
            var typeAheadItems = component.find('typeaheadOption') ? [].concat(component.find('typeaheadOption')) : [];
            var currentIndex = parseInt(event.target.dataset.index);
            
            //  down arrow
            if (keyPress == 40) {
                currentIndex = currentIndex + 1 < typeAheadItems.length ? currentIndex + 1 : 0;
                
                // up  arrow
            } else if (keyPress == 38) {
                currentIndex = currentIndex - 1 >= 0 ?  currentIndex - 1 : typeAheadItems.length -1;
            }
            
            typeAheadItems.forEach(function(elem, index){
                if (index == currentIndex) elem.getElement().focus();
            });
            event.preventDefault();
            
            // enter key
        } else if (keyPress == 13) {
            //debugger; // added by Uday
            event.preventDefault();
            var selected = helper.getFocusedTypeaheadOption(component);
            if (selected) {
                selected = selected.getElement();
                var category    = {
                    id: selected.dataset.category,
                    title: selected.dataset.categoryTitle,
                    description: selected.dataset.categoryDescription
                },
                    searchType  = selected.dataset.searchType,
                    query       = selected.dataset.keyword;
                helper.performSearch(component, helper, searchType, category, query);
                if(component.get('v.page') == 'home'){
                    //Analytics code for search
                    var analyticsData = component.find("analyticsData");
                    var type = 'search';
                    var element = 'search';
                    var detail = 'search-box: text|'+component.get('v.searchQuery');
                    analyticsData.formAnalyticsData(type,detail,element);
                    //Analytics code end
                }	
                
            } else {
                // here the user pressed ENTER on the input
                // so we use the input value and the current search type & state
                //Added by prabuddh
                var category    = {
                    id: component.get('v.state.selectedCategoryId'),//selected.dataset.category,
                    title: component.get('v.state.selectedCategoryTitle'),
                    description: component.get('v.state.selectedCategoryDescription')
                }
                helper.performSearch(component, helper,         
                                     component.get('v.searchType'),
                                     category,//component.get('v.state.selectedCategoryId'),
                                     component.get('v.searchQuery')
                                    );
                if(component.get('v.page') == 'home'){
                    //Analytics code for search
                    var analyticsData = component.find("analyticsData");
                    var type = 'search';
                    var element = 'search';
                    var detail = 'search-box: text|'+component.get('v.searchQuery');
                    analyticsData.formAnalyticsData(type,detail,element);
                    //Analytics code end
                }	
                
            }
            
            // escape key
        } else if (keyPress == 27){
            component.set('v.typeAheadOptionsVisible', false);
        }
    },
    
    handleSearchTypeChange: function(component, event, helper) {
        helper.resetPlaceholder(component);
    },
    
    handleSearchStringChange: function(component, event, helper) {
        component.set('v.searchQuery', component.get('v.searchString'));
    },
    
    handleSelectOption: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.recordId;
        var searchType = event.currentTarget.dataset.searchType;
        var label = event.currentTarget.dataset.label;
        helper.setPageName(component);
        if (recordId && (recordId != "null")) {
            helper.navigateToRecord(component, recordId);
                //Analytics code for search
                
                var analyticsData = component.find("analyticsData");
                var type = 'click';
                var element = 'search';
                // IPA2.0 + US TWC4497-1631
                // var element = (component.get('v.page') == 'search')? 'search-offerings-filter' : 'search';            
                var detail = recordId;
                var pageType = 'PartnerDetailPage';
                var href = '/s/partner/' + recordId + '/' + label.replace(/\W+/g, '-').toLowerCase();
                // IPA2.0 + US TWC4497-1631
            	// var pageType = ((searchType == 'product') ? 'OfferingDetailPage' : 'PartnerDetailPage');
                // var href = ((searchType == 'product') ? '/s/offering/'+recordId+'/' : '/s/partner/'+recordId+'/') + label.replace(/\W+/g, '-').toLowerCase(); 
                analyticsData.formAnalyticsData(type,detail,element,href, pageType);
                //Analytics code end
            
        } else {
            var category = {
                id: event.currentTarget.dataset.category,
                title: event.currentTarget.dataset.categoryTitle,
                description: event.currentTarget.dataset.categoryDescription
            };
            var searchType = event.currentTarget.dataset.searchType;
            var query = event.currentTarget.dataset.keyword;
            component.set('v.searchQuery', event.currentTarget.dataset.keyword);
            component.set('v.typeAheadOptionsVisible', false);
            helper.performSearch(component, helper, searchType, category, query);
        }
        event.preventDefault();
    },
    
    handleSearchClear: function(component, event, helper) {
        component.set('v.typeAheadOptionsVisible', false);
        component.set('v.searchClearVisible', false);
        component.set('v.searchQuery', '');
        // focus on search field
        component.find('searchInputField').focus();
    },
    
    handleSearchSubmit: function(component, event, helper) {
        event.preventDefault();
        return false;
    }
    
})