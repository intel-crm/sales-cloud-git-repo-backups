({
    /*call apex controller method "fetchContentDocument" to get salesforce file records*/
    doInit : function(component, event, helper) {
        
        var action = component.get("c.fetchContentDocument");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state****'+state);
            if (state === "SUCCESS" && response.getReturnValue()) {
                component.set("v.masterTableVariable", true);     
                var returnLibraryMap = JSON.parse(response.getReturnValue());
                let libraryList = [];
                for(var key in returnLibraryMap){
                    let returnLibraryValue = returnLibraryMap[key];
                    let contentList = [];
                    for(var content in returnLibraryValue){
                        contentList.push({key : content, value : (returnLibraryValue[content] && returnLibraryValue[content].length > 0 ? returnLibraryValue[content] : []) });
                    }
                    libraryList.push({key : key, value : (contentList && contentList.length > 0 ? contentList : []) });
                }
                component.set("v.libraryList", libraryList);
                component.set("v.unfilteredLibraryList", libraryList);
            }
            else if (state === "INCOMPLETE") {
                console.log('INCOMPLETE****');
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log('errors****'+errors);
                    if (errors) {
                    
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);  
    },
    
    getMetadataRecords : function(component){
       var action = component.get("c.getMetaDataRecords");
        
        action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
                let libraryRecordList = response.getReturnValue();
                component.set("v.libraryRecordList" , libraryRecordList);
            } else if (state === "ERROR") {
                console.log(response);
            }
		});
		$A.enqueueAction(action);
    },
    
    getSelected : function(component,event,helper){
        // display modle and set seletedDocumentId attribute with selected record Id   
        component.set("v.hasModalOpen" , true);
        component.set("v.selectedDocumentId" , event.currentTarget.getAttribute("data-Id")); 
        
    },
    closeModel: function(component, event, helper) {
        // for Close Model, set the "hasModalOpen" attribute to "FALSE"  
        component.set("v.hasModalOpen", false);
        component.set("v.selectedDocumentId" , null); 
    },
    
    handleInputChange : function(component, event, helper){
        //user input throtelling
        let searchTimeout = component.get('v.searchTimeout');
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }
        console.log('searchTimeout*****');
        console.log(searchTimeout);
        // Set new timeout
        searchTimeout = window.setTimeout(
            $A.getCallback(() => {
                
                //call for the new records
                helper.searchFilesWithTitle(component,event);
                
                // Clear timeout
                component.set('v.searchTimeout', null);
            }),
                300 // Wait for 300 ms before sending search request
                );
                
                //reset the search timeout
                component.set('v.searchTimeout', searchTimeout);
    }
    
})