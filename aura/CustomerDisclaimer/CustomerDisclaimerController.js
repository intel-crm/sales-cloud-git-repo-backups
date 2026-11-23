({
    doInit : function(component, event, helper) {
        component.set("v.hideButton",true);                  
        console.log("controller code");
        
        helper.getResourceName(component);
    },
    
    scroll : function(component, event, helper) {
        var s = component.find("scrollDiv");
        
        s = s.getElement();
        console.log(s); 
        if( s.scrollBottom()){
            //alert('2');
            // console.log("scrolled to bottom");
        }
        
    },
    onAcceptanceChange: function(component, event, helper) {
        var c = event.getSource().get('v.checked');
        if(c==true){
            var x = component.get("v.accepted");
            component.set('v.accepted', true);
            component.set('v.hideButton', false);
        }
        else{
            component.set('v.accepted', false);
            component.set('v.hideButton', true);}
        
    },   
    
    handleOnAgree: function(component, event, helper) {
        // alert('handleOnAgree ctrl');    
        helper.handleOnAgreeHelper(component);    
        
    }
})