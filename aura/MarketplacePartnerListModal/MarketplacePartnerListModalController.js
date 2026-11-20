({
	doInit : function(component, event, helper) {
		helper.groupTags(component, helper);


		component.set('v.onApplyClick', function(){
			// Apply draft to context

			helper.dispatch(component, 'contextApplyDraftToContext', {});

			$A.enqueueAction(component.get('c.handleToggleOverlay'));

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
		helper.dispatch(component, 'categorySearch', searchParams);
		});

		component.set('v.onCancelClick', function(){
			$A.enqueueAction(component.get('c.handleToggleOverlay'));

			helper.dispatch(component, 'contextResetDraft', {});
		});

	},
	handleTagsUpdate : function(component, event, helper) {
		// ISGL2PartnerListGroupingNode
		helper.groupTags(component, helper);
	},

	handleToggleOverlay : function(component, event, helper) {
		var onclick = component.get('v.onclick');
		if (typeof onclick === 'function') {
			onclick(component, event, helper);
		}
		event.preventDefault();
	},
	handleJumpScroll : function(component, event, helper) {
			var jumpId = event.currentTarget.dataset.jumpId;
			var scrollTo;
			var jumpSection;
			var jumpHeadings = component.find('jumpHeading');
			var modalBody = component.find('modalBody')
			jumpHeadings.forEach(function(entry){
				var elem = entry.getElement();
				if (elem.dataset.jumpId == jumpId){
					jumpSection = elem;
				}
			})


			if (jumpSection) {
				scrollTo = jumpSection.offsetTop; 
				modalBody.getElement().scrollTop = scrollTo;
			}

			event.preventDefault();
		}
})