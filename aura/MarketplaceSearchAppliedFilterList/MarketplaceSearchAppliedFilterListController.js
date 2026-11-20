({
    doInit: function(component, event, helper) {
        // var categoryId = component.get('v.category.categoryId');
        // var categoryType = component.get('v.category.categoryType');
        component.set('v.mapStateToAttributes', function(state) {
            var filtersList = state.filters || [];
            var selectedFilters = state.selectedFilters;
            var newRenderList = [];
            // For Each filters
            filtersList.forEach(function(tagset){
                var tagId = tagset.name;
                var selectedList  = tagset.tags;
                var selectedTags = selectedFilters[tagId] ? selectedFilters[tagId] : [];
                var childrenCount;
                if (tagset.type === 'tag') {
                    selectedList.forEach(function(element) {
                        var parentIsSelected = (selectedTags.indexOf(element.value) !== -1);
                        if (parentIsSelected) {
                            // console.log('HERE', element.children);
                            // Go through each children, only count the ones with values
                            childrenCount = element.children.reduce(function(total, cat) {
                                return  ((selectedTags.indexOf(cat.value) !== -1) && cat.count ? total + 1 : total);
                            }, 0);
                            
                            newRenderList.push({
                                name: element.label + (childrenCount ? ' + ' + childrenCount: ''),
                                id: element.value,
                                parentId: '',
                                tagListId: tagId,
                                hasChildren: element.children.length > 0
                            });
                            
                            // for multi dimensional ones, we need to get children of children count
                            
                        } else if (element.children.length) {
                            // add children if parent is not selected
                            element.children.forEach(function(element2) {
                                if (element2.count && selectedTags.indexOf(element2.value) !== -1) {
                                    newRenderList.push({
                                        name:element2.label,
                                        id: element2.value,
                                        parentId: element.value,
                                        tagListId: tagId,
                                        hasChildren: false
                                    });
                                }
                            });
                        }
                    });
                } else  if (tagset.type === 'partnerfilter') {
                    // TODO add count from selected here
                    selectedList.forEach(function(element) {
                        // console.log(selectedTags, tagId);
                        var itemIsSelected = (selectedTags.indexOf(element.value) !== -1);
                        if (itemIsSelected) {
                            newRenderList.push({
                                name: element.label,
                                id: element.value,
                                parentId: '',
                                tagListId: tagId,
                                hasChildren: false
                            });
                        }
                    });
                } else if (tagset.type === 'multilevel') {
                    // level 0 Selection doesn't auto select children
                    // level 0 Selected CAN possible have no children selected under it if its selected
                    // level 0 NOT Selected WILL have no children selected
                    selectedList.forEach(function(element) {
                        // LEVEL 0 
                        // if (selectedTags.indexOf(element.value) !== -1) {
                        // if Level 0 is selected count the inner children
                        var childrenCount = 0;
                        
                        var countSelectedChildren = function(n, level) {
                            var selectedCount = 0;
                            // if current parent is selected
                            if (level != 0 && selectedTags.indexOf(n.value) !== -1) {
                                selectedCount += 1;
                            }
                            if (n.children && n.children.length){
                                n.children.forEach(function(c){
                                    var r = countSelectedChildren(c, level+1);  
                                    selectedCount += r;
                                });
                            }
                            return selectedCount;
                        }
                        var childrenCount = countSelectedChildren(element, 0);
                        
                        if (childrenCount> 0 || (selectedTags.indexOf(element.value) !== -1)){
                            newRenderList.push({
                                name: element.label + (childrenCount ? ' + ' + childrenCount: ''),
                                id: element.value,
                                parentId: '',
                                tagListId: tagId,
                                hasChildren: element.children.length > 0
                            });
                        }
                        // }
                    });
                }
            });
            
            return {
                renderList: newRenderList,
                selectedFilters: state.selectedFilters,
                searchString: state.searchString,
                filters: state.filters
            };
        });
        
        
        
    },
    
    handleClearSearch : function(component, event, helper) {
        helper.dispatch(component, 'clearSearch');
        //Change added by prabuddh for clearing search
        var currentState = component.get('v.state');
        var searchParams = {
            keyword: '',
            category: currentState.selectedCategoryId,
            searchType: currentState.searchType,
            sortField: currentState.sortField,
            sortDirection: 'DESC',
            selectedFilters: currentState.selectedFilters,
            currentPage: currentState.currentPage,
            pageSize: currentState.pageSize,
            langCode: $A.get("$Locale.langLocale"),
            isSearchCleared: true
        };
        helper.dispatch(component, 'search', searchParams);
        helper.dispatch(component, 'categorySearch', searchParams);
        //change ends
        
    },
    
    handleRemoveTag : function(component, event, helper) {
        helper.dispatch(component, 'toggleContextFilter', {
            toggle: false,
            id: event.currentTarget.dataset.id,
            parentId: event.currentTarget.dataset.parentId,
            tagListId: event.currentTarget.dataset.tagListId,
            hasChildren: event.currentTarget.dataset.hasChildren == 'true'
        });
        
        var currentState = component.get('v.state');
        let selectedFilters = currentState.selectedFilters;
        currentState.filters.find(function(tag) {
            console.log(':::event.currentTarget.dataset.tagListId:::', event.currentTarget.dataset.tagListId, ':::', tag.name);
            if(tag.name === event.currentTarget.dataset.tagListId && tag.type == "multilevel") {
                delete selectedFilters[event.currentTarget.dataset.tagListId];
            }
        })
        var searchParams = {
            keyword: currentState.searchString,
            category: currentState.selectedCategoryId,
            searchType: currentState.searchType,
            sortField: currentState.sortField,
            sortDirection: 'DESC',
            selectedFilters: selectedFilters,
            currentPage: currentState.currentPage,
            pageSize: currentState.pageSize,
            langCode: $A.get("$Locale.langLocale")
        };
        helper.dispatch(component, 'search', searchParams);
        helper.dispatch(component, 'categorySearch', searchParams); //Added by Nikhil to update tree count//
    }
})