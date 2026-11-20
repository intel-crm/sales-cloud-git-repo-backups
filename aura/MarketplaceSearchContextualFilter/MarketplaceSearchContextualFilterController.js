(
    {
        doInit : function(component, event, helper) {
            $A.enqueueAction(component.get('c.handleStateChange'));
        },
        
        handleStateChange : function(component, event, helper) {
            var selectedList = component.get('v.selectedList');
            var selectedListId = component.get('v.selectedListId');
            var count = component.get('v.count');
            var id = component.get('v.id');
            var select = false;
            
            if (parseInt(count) !== 0 && selectedList && selectedList[selectedListId]){
                select = selectedList[selectedListId].indexOf(id)>-1;
            }
            
            component.set('v.selected',  select);
        },
        
        handleSelectTag : function(component, event, helper) {
            var checkboxValue = component.find('checkboxTag').get('v.value');
            console.log('checkBoxValue : ' , checkboxValue);
            console.log('taglistId : ' , component.get('v.selectedListId'));
            console.log('id : ', component.get('v.id'));
            console.log('parentId : ', component.get('v.parent'));
            if (component.get('v.applyToDraft')) {
                // Apply to draft do not do search
                helper.dispatch(component, 'toggleContextFilter', {
                    toggle: checkboxValue,
                    tagListId: component.get('v.selectedListId'),
                    id: component.get('v.id'),
                    parentId: component.get('v.parent'),
                    hasChildren: component.get("v.children") && component.get("v.children").length > 0,
                    draft: true
                });
                
                
            } else {
                helper.dispatch(component, 'toggleContextFilter', {
                    toggle: checkboxValue,
                    tagListId: component.get('v.selectedListId'),
                    id: component.get('v.id'),
                    parentId: component.get('v.parent'),
                    hasChildren: component.get("v.children") && component.get("v.children").length > 0
                });
                
                
                
                var currentState = component.get('v.state');
                
                
                var searchParams = {
                    keyword: currentState.searchString,
                    category: currentState.selectedCategoryId,
                    searchType: currentState.searchType,
                    sortField: currentState.sortField,
                    sortDirection: 'DESC',
                    selectedFilters: currentState.selectedFilters,
                    currentPage: 1,//currentState.currentPage,
                    pageSize: currentState.pageSize,
                    langCode: $A.get("$Locale.langLocale")  
                    
                };
                
                helper.dispatch(component, 'search', searchParams);
                helper.dispatch(component, 'categorySearch', searchParams);//Added by Nikhil to update tree count//
            }
        },
        
        
    })