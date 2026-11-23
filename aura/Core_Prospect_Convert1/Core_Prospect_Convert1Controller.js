({
	handleLeadCreation : function(component, event, helper) {
        console.log('i am here');
		
	},

   onCheck : function(component, event, helper) {
        console.log('i am here Check');
       var selected = component.find("myCheckbox");
       
       //component.set("v.newLeadCheckbox",true);
        var selected1 = component.get("v.newLeadCheckboxValue");
       
       if(selected1=true){
           component.set("v.exsLeadCheckboxValue",false);
       }
         console.log('i am here Check'+selected);
         console.log('i am here Check'+selected1);
        //console.log('i am here Check'+selected2);
         
       // alert(selected);
		
	},
    onCheck1 : function(component, event, helper) {
         var selected2 = component.get("v.exsLeadCheckboxValue");
        if(selected2=true){
           component.set("v.newLeadCheckboxValue",false);
       }
       
    } 
})