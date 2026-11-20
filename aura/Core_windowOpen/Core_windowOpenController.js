({
    doInit : function(component, event, helper) {
        var getrecordId =component.get("v.RecordId");
        if(component.get("v.isAccTeamRelated") == 'true'){
            window.open("/lightning/r/"+getrecordId+"/related/AccountTeamMembers/view", 'newwindow', 'width=1200,height=700,top=100,left=100'); return false;
        }else{
            window.open("/"+getrecordId, 'newwindow', 'width=1200,height=700,top=100,left=100'); return false;
        }
    }
    
  
})