({
	//Handle Yes and No Scenario
    handleYes : function(component,event,helper){
        helper.sendChoiceYes(component);
    },
    handleNo : function(component,event,helper){
        helper.sendChoiceNo(component);
    }
})