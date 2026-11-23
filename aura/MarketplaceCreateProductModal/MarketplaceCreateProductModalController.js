({
    
   doInit : function(component, event, helper) {
           component.set('v.loading', true);
       	   // server call to fetch all the top level categories
           helper.callServer(component,"getCategoryList").then(
           function(response){
           		var categoryObject=new Object();
                categoryObject.categories=[];
                if(response){
                    //getting all the top level categories
                	var categories=JSON.parse(response);
                   //iterating over all the top level categories
                   for(var cat of categories){
                     //populating the categoryObject fields with the received response
                     categoryObject.categories.push({name:cat.localName,
                                                     engName:cat.englishName,
                                                     id:cat.id,
                                                     icon:cat.imageURL,
                                                     description:cat.description});
                  }
                }
               component.set('v.categories', categoryObject.categories); 
           });
       
          var category = component.get("v.category");
          var isOpen = component.get("v.isOpen");
          if (!category) {
             component.set("v.isOpen", true);
          } else {
             component.set("v.isOpen", false);
         }
   },

   handleSelectCategory : function(component, event, helper) {
       
      var category = event.currentTarget.id;
      component.set('v.category', category);
      if (category != null) {
         component.set("v.isOpen", false);
      }
   },

    openModal: function(component, event, helper) {
       // for Display Model,set the "isOpen" attribute to "true"
       component.set("v.isOpen", true);
    },

    closeModal: function(component, event, helper) {
       //if previous page attribute is true - navigate to previous page
       //else if false close modal
       var navigateToPreviousPage = component.get("v.previousPage");
       if (navigateToPreviousPage) {
         window.history.back();
       } else {
         var category = component.get("v.category");
         if (!category) {
            //alert($A.get("$Label.c.PMP_CategorySelectionRequired"));
         } else {
            component.set("v.isOpen", false);
         }
       }
    }
 })