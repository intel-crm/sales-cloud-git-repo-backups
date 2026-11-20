({
    doInit : function(component, helper) {
        
        component.set("v.options", component.get("v.typeOptions") || []);
        
        var isOpen = component.get("v.isOpen");
        if (!isOpen) {
           component.set("v.isOpen", false);
        } else {
           component.set("v.isOpen", true);
       }
       //set v._rows to v.rows
       //clone object
       component.set("v._rows", component.get('v.rows') || []);
       //helper.validate(component);
    },

    handleClick: function(component, event, helper) {
        var id = event.target.dataset.idx
        console.log('dropdownidclicked', id);
        helper.validate(component);
    },

    handleAddResource: function(component, event, helper) {
        var rows = component.get('v._rows') || [];
        rows.push({ title: '', url: '', type: ''});
        component.set('v._rows', rows);
        component.set("v.isFormValid", false);
        component.set("v.hideButton",true);
    },

    openModal: function(component, event, helper) {
       component.set("v.isOpen", true);
       $A.util.addClass(document.body,'modal-open-no-scroll');
       // TODO add body overrride on css
       document.body.style.overflowY = 'hidden';
    },
  
    closeModal: function(component, event, helper) {
       component.set("v.isOpen", false);
       helper.validate(component);
       $A.util.removeClass(document.body,'modal-open-no-scroll');
       // TODO add body overrride on css
       document.body.style.overflowY = '';
    },

    saveModal: function(component, event, helper) {
        //Save Modal Logic
        //prevent user to save until modal until form is valid
        component.set("v.rows", component.get('v._rows'));
        component.set("v.isOpen", false);
        $A.util.removeClass(document.body,'modal-open-no-scroll');
        // TODO add body overrride on css
        document.body.style.overflowY = '';
     },

     handleDelete : function(component, event, helper) {
            var rows = component.get('v._rows') || [];
            var toDeletIndex =  event.target.dataset.idx
            rows.splice(toDeletIndex, 1);
            component.set("v._rows", rows);
            helper.validate(component);
             if(rows.length > 0){
                component.set("v.isFormValid", true); 
             }else{
                component.set("v.isFormValid", false); 
             }
             
              component.set("v.hideButton",false);
            
    },

    handleChange: function(component, event, helper) {
        console.log('handleChange');
     
        event.getSource().reportValidity();
        
        helper.validate(component);
    },

    handleDropdownChange: function(component, event, helper) {
        var valid = event.getSource().checkValidity();
        /*Raj's changes to get the label of the option*/
        var options = component.get('v.options');
        var value = event.getSource().get("v.value");
        var index = options.findIndex(item => item.value == value),
    	optionLabel = index >= 0? options[index].label: null;
        var row = component.get('v._rows')[event.target.dataset.idx];
        row.label = optionLabel;
        /*End*/
        //var valid = component.find("dropdown").checkValidity();
        component.set('v.valid', valid);
        helper.validate(component);
    },
    
   
    
     handleBlur: function(component, event, helper) {
        
       var isUrlGreatherThan255 = false;
        var resourceJSON = component.get('v._rows')[0];
         component.set('v.hasError',false);
         var resorceUrlCheck = JSON.stringify(resourceJSON.url);
      
        
         if( (resorceUrlCheck.length - 2) > 255){
                isUrlGreatherThan255 = true;
              helper.checkUrlError(component, helper, $A.get("$Label.c.PMP_Url_Length_Check"));
                
         }else{
             helper.checkUrlNoError(component,helper);
             helper.validate(component);
         }
         
      //helper.validate(component);
     }
 })