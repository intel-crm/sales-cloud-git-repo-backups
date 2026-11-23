({
    getImages : function(component, helper) {
        return new Promise(function(resolve, reject) {
            var action = component.get("c.getImages");
            action.setParams({ offeringId: component.get('v.recordIdForUpload') });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('images from server call');
                    var images = JSON.parse(response.getReturnValue());
                    var extensions = component.get('v.acceptableFormats');
                    var l;
                    console.log('getImages Return if [] it means you are not logged in ',images);
                    images = images.filter(function(i) {
                        // IE 11 does not support Array.find 
                        // return extensions.find(function(e) { return i.title.match(e); });
                        if (extensions) {
                            for (l = 0; l < extensions.length; l++) {
                                if (i.title.match(extensions[l])) {
                                    return true;
                                }
                            }
                        }
                        return false;

                    });
                    component.set('v.images', images);
                    resolve();
                }
                else if (state === "INCOMPLETE") {
                    reject(); // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    reject(errors);
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
        });
    },

    deleteImage : function(component, helper) {
        component.set('v.deleting', true);
        var images = component.get('v.images');
        var imageIdx = component.get('v.imageToDelete');
        var imageId = images[imageIdx].id;
        var action = component.get("c.deleteImage");
        action.setParams({ contentDocumentId: imageId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('delete status :',state)
            if (state === "SUCCESS") {
                
                var idx = component.get('v.imageToDelete');
                var images = component.get('v.images');
                images.splice(idx, 1);
                component.set('v.images', images);
                component.set('v.imageToDelete', null);
                component.set('v.deleting', false);
                helper.isValid(component, helper);
                component.set('v.showInvalid', !component.get('v.valid'));
                //added by Nikhil as part of US583440
                if(component.get("v.isEvent")){
                    var eventAction = component.get("c.deleteBannerMapping");
                    eventAction.setParams({ 
                        eventId: component.get("v.recordIdForUpload"),
                        docId : imageId
                    });
                    eventAction.setCallback(this, function(response) {
                        var status = response.getState();
                        console.log('delete mapping status',status)
                        
                    });
                    $A.enqueueAction(eventAction);
                }
                //End
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                component.set('v.imageToDelete', null);
                component.set('v.deleting', false);
                var errors = response.getError();
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

    isValid : function(component, helper) {
        var valid = component.get("v.required") ? component.get('v.images').length > 0 : true;
        component.set("v.valid", valid);
        helper.updateForm(component);
        
    },
    
    //for US357476 to handle uploaded file and perform validations
    handleUpload:function(component, event, helper){
        console.log('Inside handle upload');
        var currentFiles = event.getParam("files");//gives the information (Id and name) of file which is uploded
        console.log('files fetched');
        var idx;
        var contentDocumentRecord=new Object();
        var isDuplicate=false;
        var maxFileSize = 5000000;//setting maxFileSize to 5Mb
		console.log(currentFiles[0].documentId);
        var action=component.get("c.getContentDocument");//server call to get contentDocument record
        action.setParams({documentID:currentFiles[0].documentId});//setting params as documentId of uploaded file
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state="SUCCESS"){
                var existingFiles=component.get('v.images');//getting all the existing image related to that offering
                contentDocumentRecord=response.getReturnValue();//getting the contentDocument record of the current file
        		console.log('contentDocument-->'+contentDocumentRecord.ContentSize+"->"+existingFiles.length);
                console.log("@name", currentFiles[0].name);
                console.log("@existingFiles", existingFiles);
                if(existingFiles.length!=0){
                    for(var rowIndex=0;rowIndex<existingFiles.length;rowIndex++){//iterating over all the files related to that offering
                        if(existingFiles[rowIndex].title == currentFiles[0].name && 
                           existingFiles[rowIndex].size == contentDocumentRecord.ContentSize &&
                           existingFiles[rowIndex].id != currentFiles[0].documentId){//checking if a file of same name and size exists
                           isDuplicate=true;
                        }
                        if(existingFiles[rowIndex].id == currentFiles[0].documentId){
                           idx=rowIndex;//index of currently uploaded file in existingFiles array 
                        }
                    }
            	}
                if(contentDocumentRecord.ContentSize<maxFileSize){//checking if the current file size is less than the recommended size
                    if(isDuplicate){//checking if it's a duplicate file
                        //if the validation fails delete the file and show error message
                        component.set('v.imageToDelete',idx);//setting the file index that is to be deleted
                        helper.deleteImage(component, helper);//calling delete method
						helper.hasError(component, helper,$A.get("$Label.c.Core_PMP_DuplicateFileNameError"));//calling hasError method with error message
                    }
                    else{
                        helper.hasNoError(component, helper);//calling hasNoError method
                    }
                }
                else{
                    //if the validation fails delete the file and show error message
                    component.set('v.imageToDelete',idx);//setting the file index that is to be deleted 
                    helper.deleteImage(component, helper);//calling delete method
					helper.hasError(component, event,$A.get("$Label.c.Core_PMP_AttachmentError"));//calling hasError method with error message
                }
        	}
        });
        $A.enqueueAction(action);
    },
    
    /*Added by raj for US357476 to handle the error*/
    hasError : function(component, helper, label){
        component.set('v.hasError', true);
        component.set('v.error',label); 
        var cmpTarget = component.find('input'); 
        $A.util.addClass(cmpTarget, 'slds-has-error');
        
    },
    /*Added by raj for US357476 to handle no error*/
    hasNoError : function(component, helper){
        component.set('v.hasError', false);
        var cmpTarget = component.find('input'); 
        $A.util.removeClass(cmpTarget, 'slds-has-error');   
    }, 
    /*---------------------------End US357476-------------------------------------*/
    
    //added by Nikhil as part of US583440
    updatePromotionBannerMapping: function(component, event, helper){
        console.log('updatePromotionImageMapping');
        var files = event.getParam("files");
        
        var docId = files[0].documentId;
        
        var action = component.get("c.updateBannerMapping");
        action.setParams({
            eventId:component.get("v.recordIdForUpload"),
            lang: component.get("v.language"),
            docId: docId
        });
        action.setCallback(this, function(response) {
                var status = response.getState();
            	console.log('Logo mapping status',status)
                if (status === "SUCCESS") {
                    
                } else if (status === "INCOMPLETE") {
                    // do something?
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                } else {
                    reject('Unknown error.');
                }
            });
            $A.enqueueAction(action);
    },
    
    //Changes End
    showErrorMessage : function(component, helper) {
        component.set('v.showInvalid', !component.get('v.valid'));
    }
})