({
    
    doInit: function(component, event, helper) {
        var categoryId = component.get('v.category.categoryId');
        var categoryType = component.get('v.category.categoryType');
        
        component.set('v.mapStateToAttributes', function(state) {
            var isOpen, isSelected;
            if (categoryId) {
                isOpen = state.categories.expanded.indexOf(categoryId) > -1;
                
                isSelected = state.selectedCategoryId == categoryId;
            } else {
                isOpen = state.categories.expanded.indexOf(categoryType) > -1;
                
                isSelected = !state.selectedCategoryId && state.searchType == categoryType;
            }
            
            return {
                open: isOpen,
                selected: isSelected
            };
        });
    },
    
    handleToggleOpenCategory : function(component, event, helper) {
        event.preventDefault();
        
        helper.dispatch(component, 'toggleCategoryNode', {
            value: component.get('v.category.categoryId') || component.get('v.category.categoryType')
        });
    },
    
    handleSelectCategory : function(component, event, helper) {
        event.preventDefault();
        
        if (String(component.get('v.category.count')) == '0') return;
        helper.dispatch(component, 'selectSearchCategory', {
            categoryId: component.get('v.category.categoryId'),
            categoryType: component.get('v.category.categoryType'),
            categoryTitle: component.get('v.category.categoryName'),
            categoryDescription: component.get('v.category.categoryDescription'),
            //categoryCtaLink: 'https://www.intel.com' //Commented since cat link is dynamic not static : Prabuddh 
            categoryCtaLink: component.get('v.category.categoryCtaLink')
        });
           
        var searchParams = {
            keyword: component.get('v.state.searchString'),
            category: component.get('v.category.categoryId'),
            searchType: component.get('v.category.categoryType'),
            sortField: component.get('v.state.sortField'),
            sortDirection: component.get('v.state.sortDirection'),
            selectedFilters: component.get('v.state').selectedFilters,
            currentPage: 1,
            pageSize: component.get('v.state.pageSize'),
            langCode: $A.get("$Locale.langLocale"),
            isCategoryNodeClicked: true
        };
        console.log(':::category filter controller:::');
        helper.dispatch(component, 'search', searchParams);
        helper.dispatch(component, 'categorySearch', searchParams);
        
        
    },
    
})