({

  doInit: function(component, event, helper) {
    component.set('v.mapStateToAttributes', function(state) {
      return {
        isMobile: state.currentSldsBreakPoint != 'x-large'
      };
    });

    var checkboxes = component.get("v.initialState") || [];
    var initialList = component.get("v.initialSelectedList") || [];
    var selectedListSet = new Set();

    initialList.forEach(function(item) { selectedListSet.add(item); });
    component.set("v.selectedListSet", selectedListSet);
    var recurse = function(boxes) {
      boxes.forEach(function(box) {
        box.checked = selectedListSet.has(box.value);
        if (box.children && box.children.length) {
          recurse(box.children);
        }
        selectedListSet.delete(box.value);
      });
    };
    recurse(checkboxes);
    component.set("v.checkboxes", checkboxes);

    console.log('MarketplaceMultilevelModal.init', checkboxes, initialList, selectedListSet)
    component.set("v.onchange", $A.getCallback(function(cmp) {
        var value = component.find("options").get("v.value");
        var newValue = new Set();
        selectedListSet.forEach(function(item) {
          newValue.add(item);
        });
        value.forEach(function(item) {
          newValue.add(item);
        });
        component.set("v.selectedListSet", newValue);
      })
    );
      
      component.set("v.onchangelwc", function(cmp) {	
      var value = cmp.value || [];	
      var newValue = new Set();	
      console.log('Options Selected',value, selectedListSet);
      selectedListSet.forEach(function(item) {	
        newValue.add(item);	
      });	
      value.forEach(function(item) {	
        newValue.add(item);	
      });	
      component.set("v.selectedListSet", newValue);	
    });	
      

    // reset object on every init
    var options = component.find('options');
    if (options && options.reset ) options.reset();
    
  },

    handleApply: function(component, event, helper) {
        var selectedFilters = [];
        component.get("v.selectedListSet").forEach(function(item) {
            selectedFilters.push(item);
        });console.log(':::isMobile:::', component.get('v.isMobile'));
        if (component.get('v.isMobile')) {
            // Apply to draft do not do search
            helper.dispatch(component, 'selectGroupFilters', {
                filterId: component.get('v.filterId'),
                selectedFilters: selectedFilters,
                draft: true
            });
        } else {
            var selectPayload = {
                filterId: component.get('v.filterId'),
                selectedFilters: selectedFilters
            };
            helper.dispatch(component, 'selectGroupFilters', selectPayload);
            
            var currentState = component.get('v.appState.Search');
            /*
            var searchParams = {
                keyword: currentState.searchString,
                category: currentState.selectedCategoryId,
                searchType: currentState.searchType,
                sortField: 'sortField',
                sortDirection: 'DESC',
                selectedFilters: currentState.selectedFilters,
                currentPage: currentState.currentPage,
                pageSize: currentState.pageSize
            };
            */
            var searchParams = {
                keyword: currentState.searchString,
                category: currentState.selectedCategoryId,
                searchType: currentState.searchType,
                sortField: currentState.sortField,
                sortDirection: 'DESC',
                selectedFilters: currentState.selectedFilters,
                currentPage: 1,
                pageSize: currentState.pageSize,
                langCode: $A.get("$Locale.langLocale")  
            };
            
            helper.dispatch(component, 'search', searchParams);
            helper.dispatch(component, 'categorySearch', searchParams); //Added by Subash to update tree count
        }
        helper.close(component, event, helper);
    },

  handleCancel : function(component, event, helper) {
    helper.close(component, event, helper);
  },

  handleReset :  function(component, event, helper) {
    console.log('MultiModalHandleReset');
  }
});