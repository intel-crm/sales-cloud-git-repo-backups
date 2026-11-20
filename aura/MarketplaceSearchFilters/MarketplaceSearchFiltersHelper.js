({
    toggleModal: function(component, helper, modalId) {
        var modalOpen = component.get("v." + modalId + "Open");
        var overlayElement = document.getElementById(modalId);
        var backdropElement = document.getElementById(modalId + "Backdrop");
        modalOpen = !modalOpen;
        
        try {
            component.set("v." + modalId + "Open", modalOpen);
        } catch (e) {
            console.log("error on Toggle Modal", e, modalId);
        }
        // have to manually change it here as transitions wont work if we do it inline
        if (modalOpen) {
            overlayElement.classList.remove("slds-hide");
            
            window.setTimeout(
                $A.getCallback(function() {
                    overlayElement.classList.add("slds-show");
                }),
                5
            );
            $A.util.addClass(document.body, "modal-open-no-scroll");
            // TODO add body overrride on css
            document.body.style.overflowY = "hidden";
            
            backdropElement.classList.add("slds-show");
            backdropElement.classList.remove("slds-hide");
            // Reset Partner selected filter Draft
            if (modalId === "partnerModal") {
                helper.dispatch(component, "contextResetDraft", {});
            }
        } else {
            $A.util.removeClass(document.body, "modal-open-no-scroll");
            // TODO add body overrride on css
            document.body.style.overflowY = "";
            
            overlayElement.classList.remove("slds-show");
            backdropElement.classList.remove("slds-show");
            backdropElement.classList.add("slds-hide");
            if (
                component.get("v.appState.Settings.currentSldsBreakPoint") != "x-large"
            ) {
                window.setTimeout(
                    $A.getCallback(function() {
                        overlayElement.classList.add("slds-hide");
                    }),
                    600
                );
            } else {
                overlayElement.classList.add("slds-hide");
            }
        }
    },
    
    setMultiLevelModalData: function(component, event, helper, modalType) {
        var currentState = component.get("v.state");
        var l0FilterId = event.target.dataset.modalL0filterId;
        var contextId = event.target.dataset.modalContextId;
        var selectedTagSet, selectedSubTag;
        var selectedFilters = modalType != 'draft' ? currentState.selectedFilters : currentState.selectedDraftFilters;
        
        if (contextId && l0FilterId) {
            selectedTagSet = currentState.filters.find(function(tag) {
                return tag.name === contextId;
            });
            if (selectedTagSet && selectedTagSet.tags) {
                selectedSubTag = selectedTagSet.tags.find(function(subTag) {
                    return subTag.value === l0FilterId;
                });
            }
            
            component.set("v.multilevelTitle", event.target.dataset.modalTitle);
            component.set("v.multilevelID", contextId);
            //component.set(
            //    "v.multilevelFilterList",
            //    selectedSubTag ? selectedSubTag.children : []
            //);
            component.set(	
                "v.multilevelFilterList",	
                selectedSubTag ? [].concat(selectedSubTag) : []	
            );
            component.set(
                "v.multilevelSelectedList",
                selectedFilters[contextId]
                ? selectedFilters[contextId]
                : []
            );
        }
    },
    
   /* getFilterTags: function(component, filters){
        setTimeout($A.getCallback(function(){
            var getTags = component.get("c.getPartnerPrograms");
            getTags.setParams({
                langCode: $A.get("$Locale.langLocale")
            }); 
            getTags.setBackground();
            getTags.setCallback(this,function(response){
                var status = response.getState();
                if(status =="SUCCESS"){
                   var returnValue = response.getReturnValue();
                    console.log('get tags server call ',returnValue);
                    component.set('v.filters', null);
                }else if (status === "INCOMPLETE") {
                    // do something?
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                } else {
                    console.log('Unknown error.');
                }
            })
            $A.enqueueAction(getTags);
        }))
    }  *///Lazy loading for contextual filters
});