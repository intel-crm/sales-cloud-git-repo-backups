({
    
    doInit : function(component, event, helper) {
    //merge changes 22-Oct-2019
        var filterOpenState = component.get('v.filterOpenState') || {};
        component.set('v.filterOpenState', filterOpenState); 
       
        component.set('v.mapStateToAttributes', function(state) {
            console.time('PERF-L2SearchTree-RenderTime');
            console.time('PERF-L2SearchTree-StateUpdateProcessing'); 
            var filtersList = state.filters || [];
            var filterGroup = {};
            var selectedFilters = state.selectedFilters;
            var actualSelectedCount = 0;
            // For Each filters
            filtersList.forEach(function(tagset){
                var tagId = tagset.name;
                var selectedList  = tagset.tags;
                var selectedTags = selectedFilters[tagId] ? selectedFilters[tagId] : [];
                var childrenCount;
                var filterGroupCount = 0;    
                
                if (tagset.type === 'tag') {
                    selectedList.forEach(function(element) {
                        var parentIsSelected = (selectedTags.indexOf(element.value) !== -1);
                        if (parentIsSelected) {
                            // Go through each children, only count the ones with values
                            childrenCount = (element.children || []).reduce(function(total, cat) {
                                //merge changes 22-Oct-2019
                                return  ((selectedTags.indexOf(cat.value) !== -1) && cat.count ? total + 1 : total);
                            }, 0);
                            filterGroupCount += childrenCount + 1 ;// add the parent
                        } else if (element.children.length) {
                            // add children if parent is not selected
                            element.children.forEach(function(element2) {
                                if (selectedTags.indexOf(element2.value) !== -1 && element2.count) {
                                    filterGroupCount++;
                                }
                            });
                        }
                    });
                } else  if (tagset.type === 'partnerfilter') {
                    selectedList.forEach(function(element) {
                        var itemIsSelected = (selectedTags.indexOf(element.value) !== -1);
                        if (itemIsSelected) {
                            filterGroupCount++;
                        }
                    });
	//megre changes 24-feb-2020
        } else if (tagset.type === 'multilevel') {
          selectedList.forEach(function(element) {
              var countSelectedChildren = function(n, level) {
                var selectedCount = 0;
                // if current parent is selected
                if (selectedTags.indexOf(n.value) !== -1) {
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
              filterGroupCount += countSelectedChildren(element, 0);
          });
        }
                tagset.selectedCount = filterGroupCount
                actualSelectedCount += filterGroupCount;
                filterGroup[tagId] = filterGroupCount;
            });
            
            console.timeEnd('PERF-L2SearchTree-StateUpdateProcessing');
            setTimeout($A.getCallback(function() {
                console.timeEnd('PERF-L2SearchTree-RenderTime');
            }));
            
        /*    console.log('arefilterloaded :: ', state.areFiltersLoaded);
            if(state.areFiltersLoaded){
                helper.getFilterTags(component, state.filters);
            } */ //Lazy loading for contextual filters
            
            return {
                categories: [
                    {
                        categoryId: null,
                        categoryName: $A.get('$Label.c.PMP_All_Marketplace'),
                        count: state.categories.allMarketplaceCount,
                        categoryType: "all",
                        open: true,
                        children: [
                            {
                                categoryId: null,
                                categoryName: $A.get('$Label.c.PMP_All_Products'),
                                count: state.categories.allProductCount,
                                categoryType: "product",
                                open: true,
                                children: state.categories.productCategories
                            },
                            {
                                categoryId: null,
                                categoryName: $A.get('$Label.c.PMP_All_Partners'),
                                count: state.categories.allPartnerCount,
                                categoryType: "partner",
                                open: true,
                                children: state.categories.partnerCategories
                            }
                        ]
                    }
                ],
                categoryId: state.selectedCategoryId,
                searchType: state.searchType,
                filters: state.filters,
                filterGroupCount: filterGroup,
                selectedFiltersCount: actualSelectedCount
            };
        });
        
        component.set('v.onRefineApplyClick', function(){
            //
            helper.dispatch(component, 'contextApplyDraftToContext', {});
            
            $A.enqueueAction(component.get('c.handleShowRefineOverlay'));
            // do search
            var currentState = component.get('v.state');
            var searchParams = {
                keyword: currentState.searchString,
                category: currentState.selectedCategoryId,
                searchType: currentState.searchType,
                sortField: currentState.sortField,
                sortDirection: 'DESC',
                selectedFilters: currentState.selectedFilters,
                currentPage: currentState.currentPage,
                pageSize: currentState.pageSize,
                langCode:$A.get("$Locale.langLocale")
            };
            helper.dispatch(component, 'search', searchParams);
            helper.dispatch(component, 'categorySearch', searchParams); // Added to update category tree for mobile view - Prabuddh
            
        });
        
        component.set('v.onPartnerClick', function(){
      helper.toggleModal(component, helper, 'partnerModal');
        });
        
    component.set('v.onMultilevelClick', function(){
      helper.toggleModal(component, helper, 'multilevelModal');
    });

    window.addEventListener('resize', function() {
      // make sure multilevel modal is closed when switching from mobile/desktop
      if ((component.get('v.appState.Settings.currentSldsBreakPoint') != 'x-large') && 
        component.get("v.multilevelModalOpen") && !component.get("v.refineModalOpen")){
          // close modal on mobile if refine modal is not open
          helper.toggleModal(component, helper, 'multilevelModal');
      } else if ((component.get('v.appState.Settings.currentSldsBreakPoint') == 'x-large') && 
        component.get("v.multilevelModalOpen") && component.get("v.refineModalOpen")){
          // close modal on xlarge if refine is also open
          helper.toggleModal(component, helper, 'multilevelModal');
      }
      
    });
    },
    
    handleCategoryChange: function(component, event, helper) {
        var modalOpen = component.get("v.categoryModalOpen");
        if (modalOpen){
            // close category modal if category id changed
            $A.enqueueAction(component.get('c.handleShowCategoryOverlay'));
        }
    },
    
    handleShowCategoryOverlay: function(component, event, helper) {
        var modalOpen = component.get("v.categoryModalOpen");
        var overlay = component.find('categoryOverlay');
        
        modalOpen = !modalOpen;
        component.set("v.categoryModalOpen", modalOpen);
        // have to manually change it here as transitions wont work if we do it inline
        if (modalOpen) {
            $A.util.removeClass(overlay, 'slds-hide');
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.addClass(overlay, 'slds-show');
                }), 5
            );
        } else {
            $A.util.removeClass(overlay, 'slds-show');
            $A.util.addClass(overlay, 'slds-hide');
        }
        // check if mobile prevent opening of window
        event.preventDefault();
        
    },
    //merge changes 22-Oct-2019
    handleClearAllFilters: function(component, event, helper) {
        helper.dispatch(component, 'contextClearAllFilters', {});
        
        $A.enqueueAction(component.get('c.handleShowRefineOverlay'));
        
        // do search
        var currentState = component.get('v.state');
        var searchParams = {
            keyword: currentState.searchString,
            category: currentState.selectedCategoryId,
            searchType: currentState.searchType,
            sortField: currentState.sortField,
            sortDirection: 'DESC',
            selectedFilters: currentState.selectedFilters,
            currentPage: currentState.currentPage,
            pageSize: currentState.pageSize,
            langCode: $A.get("$Locale.langLocale")
        };
        
        helper.dispatch(component, 'search', searchParams);
        helper.dispatch(component, 'categorySearch', searchParams);// Added to update category tree for mobile view - Prabuddh
    },
    handleShowRefineOverlay: function(component, event, helper) {
        var modalOpen = component.get("v.refineModalOpen");
        var overlay = component.find('refineOverlay');
        
        modalOpen = !modalOpen;
        
        component.set("v.refineModalOpen", modalOpen);
        if (modalOpen) {
            $A.util.removeClass(overlay, 'slds-hide');
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.addClass(overlay, 'slds-show');
                }), 5
            );
            // Reset Partner selected filter Draft
            helper.dispatch(component, 'contextResetDraft', { });
            
        } else {
            $A.util.removeClass(overlay, 'slds-show');
            $A.util.addClass(overlay, 'slds-hide');
        }
        event.preventDefault();
    },
    
    
  handleShowModal: function(component, event, helper) {
    var modalId = event.target.dataset.modalId;
    var modalType = event.target.dataset.modalType || 'nondraft';

    event.preventDefault();

    // check if mobile prevent opening of window
    // SPecial case for multilevelmodal
    if (modalId === 'multilevelModal') {
      helper.setMultiLevelModalData(component, event, helper, modalType);
    }
    helper.toggleModal(component, helper, modalId);

  },
    
    handleSortBy: function(component, event, helper) {
        var currentState = component.get('v.state');
        var searchParams = {
            keyword: currentState.searchString,
            category: currentState.selectedCategoryId,
            searchType: currentState.searchType,
            sortField: currentState.sortField,
            sortDirection: 'DESC',
            selectedFilters: currentState.selectedFilters,
            currentPage: 1,
            pageSize: 9,
            langCode: $A.get("$Locale.langLocale")
        };
        
        helper.dispatch(component, 'search', searchParams);
    },
    

    // MGDANIES - 10/31
    // Used to reset the expanded categories back to the default.
    // Needed to stop categories from collapsing when you click to
    // open them.
    // This code will be removed when we move to the querystring
    // parameter to indicate saving search state in local cache.
    handleDestroy: function(component, event, helper) {
    	helper.dispatch(component, 'clearExpandedCategories');
    }
    
})