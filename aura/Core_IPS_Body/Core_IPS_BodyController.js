({
	myAction : function(component, event, helper) {
		
	},
    handleBeforeSelect: function(component, event) {
        alert('ABCD');
    },
     
    handleChange : function(component, event, helper){
       console.log(event.getParam("name"));
        if(event.getParam("name") == 'My_Cases'){
            component.set("v.My_Cases", "true");
            component.set("v.My_Projects", "false");
            component.set("v.My_Products", "false");
            component.set("v.Contacts", "false");
        }else if(event.getParam("name") == 'My_Projects'){
            component.set("v.My_Projects", "true");
            component.set("v.My_Cases", "false");
            component.set("v.My_Products", "false");
            component.set("v.Contacts", "false");
        }else if(event.getParam("name") == 'My_Products'){
            component.set("v.My_Products", "true");
            component.set("v.My_Cases", "false");
            component.set("v.My_Projects", "false");
            component.set("v.Contacts", "false");
        }else if(event.getParam("name") == 'Contacts'){
            component.set("v.Contacts", "true");
            component.set("v.My_Cases", "false");
            component.set("v.My_Projects", "false");
            component.set("v.My_Products", "false");

        } 
        
    }
})