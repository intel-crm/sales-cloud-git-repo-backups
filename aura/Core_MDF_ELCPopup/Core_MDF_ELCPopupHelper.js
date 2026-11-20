({  
    // Fire PopUp EVENT based on YES or NO
    sendChoiceYes : function(component, event){
    	var updateEvent = component.getEvent("ButtonClickEvent");
        updateEvent.setParams({ "ButtonClick": true, "popupName": component.get("v.PopupType") });
        updateEvent.fire();        
	},
    sendChoiceNo : function(component, event){
    	var updateEvent = component.getEvent("ButtonClickEvent");
        updateEvent.setParams({ "ButtonClick": false, "popupName": component.get("v.PopupType") });
        updateEvent.fire();
    }
})