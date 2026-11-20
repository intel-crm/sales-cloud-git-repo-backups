({
    // IPA2.0 + US TWC4497-1631
//    doInit : function(component, event, helper) {
//            component.set('v.loading', true);
//        	   // server call to fetch all the top level categories
//            helper.callServer(component,"getCategoryList").then(
//            function(response){
//                console.log('response:::', response);
//            		var categoryObject=new Object();
//                 categoryObject.categories=[];
//                 if(response){
//                     //getting all the top level categories
//                 	var categories=JSON.parse(response);
//                    //iterating over all the top level categories
//                    for(var cat of categories){
//                      //populating the categoryObject fields with the received response
//                      categoryObject.categories.push({name:cat.localName,
//                                                      engName:cat.englishName,
//                                                      id:cat.id,
//                                                      icon:cat.imageURL,
//                                                      description:cat.description});
//                   }
//                 }
//                component.set('v.categories', categoryObject.categories); 
//            });
       
//           var category = component.get("v.category");
//           var isOpen = component.get("v.isOpen");
//           if (!category) {
//              component.set("v.isOpen", true);
//           } else {
//              component.set("v.isOpen", false);
//          }
//    },

//    handleSelectCategory : function(component, event, helper) {
       
//      var category = event.currentTarget.id;
//      var solutionRedirectionFlag = $A.get("$Label.c.PSS_SolutionCategory");
       
//        if(solutionRedirectionFlag == 'False'){
//            if (category != null ) {
//                component.set('v.category', category);
//                component.set("v.isOpen", false);
//            }
//        }
       
//        if(solutionRedirectionFlag == 'True'){
//            if (category != null && category != 'Solution|IPA_TYPE_Sol') {
//                component.set('v.category', category);
//                component.set("v.isOpen", false);
//            } 
           
//            if (category != null && category == 'Solution|IPA_TYPE_Sol') {
//                // component.set("v.isOpen", false);
//                component.set("v.solutionToastMessage", true);
               
//                if(component.get("v.solutionToastMessage") == true){
                   
//                    helper.redirectMethod(component);
//                    var baseurl = window.location.href;
//                    var currentrecordid = baseurl.split("=");
//                    var offeringid = currentrecordid[1];
//                    if(component.get("v.cancelredirect") == false){
//                        var action = component.get("c.deletecurrentOffering");
//                    }
//                    action.setParams({ 
//                        currentofferingid: offeringid
//                    });
//                    action.setCallback(this, function(actionResult){
//                        var state = actionResult.getState();
//                        if (state === "SUCCESS") {
//                            // alert(offeringid);
//                        }
//                    });
//                    $A.enqueueAction(action);
//                }
//            }
//        }
//    },
    
//     closesolutionToastMessage: function(component, event, helper) {
//         /* Set isModalOpen attribute to false */
        
//         helper.setStopTimeOnUI(component);
//     },

//     openModal: function(component, event, helper) {
//        // for Display Model,set the "isOpen" attribute to "true"
//        component.set("v.isOpen", true);
//     },

//     closeModal: function(component, event, helper) {
//        //if previous page attribute is true - navigate to previous page
//        //else if false close modal
//        var navigateToPreviousPage = component.get("v.previousPage");
//        if (navigateToPreviousPage) {
//          window.history.back();
//        } else {
//          var category = component.get("v.category");
//          if (!category) {
//             //alert($A.get("$Label.c.PMP_CategorySelectionRequired"));
//          } else {
//             component.set("v.isOpen", false);
//          }
//        }
//     }
 })