({
    
    doInit : function(component, event, helper) {
        /*
		 *Gireesh:US387913: Change default prefixURL to display image in lightning tab 
		 */
        console.log('Inside upload init');
        var match = window.location.href.match(/.*Admin_Review(.*)/);		
        // set record ID		
        if (match) {		
            component.set("v.prefixUrl","/sfc/servlet.shepherd/version/download/");		
        } 
        component.set('v.isLoading',true);
        
        
        helper.getImages(component, helper).then($A.getCallback(function() {
            component.set('v.isLoading',false);
            helper.isValid(component, helper);
        }));
        
        
        // add delete callback for confirm dialog
        component.set('v.deleteCallback', $A.getCallback(function(confirmed) {
            component.set('v.showDeleteConfirm', false);
            if (confirmed) {
                helper.deleteImage(component, helper);
            } else {
                component.set('v.imageToDelete', null);
            }
        }));
        
        if (!(window.ActiveXObject) && "ActiveXObject" in window) {
            // IE11 BUG w/ native lightning:fileUpload component
            // CAUSES ISSUE WITH IE NOT displaying already uploaded images because of the extensions filter.
            // component.set('v.acceptableFormats', null);
            component.set('v.isIE', true);
        }
    },
    
    handleUploadFinished: function (component, event, helper) {
        console.log('Inside upload finished');
        component.set("v.touched", true);
        //added by Nikhil as part of US583440
        //IPA2.0:TWC729-8114 Topics Removal/Event Removal
        /*if(component.get("v.isEvent")){
        	helper.updatePromotionBannerMapping(component, event, helper)
        }*/
        //End
        
        helper.updateOwnerInfo(component, event, helper).then($A.getCallback(function() {
            helper.getImages(component, event, helper).then($A.getCallback(function() {
                if(!component.get("v.isEvent")){
                    helper.handleUpload(component, event, helper);
                    helper.isValid(component, helper);
                    component.set('v.showInvalid', !component.get('v.valid')); 
                }
            }));
        }));
        
        //Added by Nikhil 
        /*component.set('v.logoCheck', true);
      var vx = component.get("v.method");
      $A.enqueueAction(vx);*/
  },
    
    handleReportValidity : function(component, event, helper) {
        component.set('v.showInvalid', !component.get('v.valid'));
    },
    
    // need to use currentTarget for IE11
    handleDeleteImage : function(component, event, helper) {
        component.set('v.showDeleteConfirm', true);
        component.set('v.imageToDelete', parseInt(event.currentTarget.dataset.idx));
        component.set("v.touched", true);
        /*component.set('v.logoCheck', false);
    var vx = component.get("v.method");
    $A.enqueueAction(vx);*/
  },
    
    handleDownloadImage : function(component, event, helper) {
        var index = event.currentTarget.dataset.idx;
        var imageUrl = component.get('v.images')[index].url;
        window.open(imageUrl);
    },
    
})