({
    handleClose: function (component,event, helper) {
    
        const detail =  event.getParam('isDealSubmitted');
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        const dealRegListViewlabel =$A.get("$Label.c.IPA_DealRegHome_Url");
        const dealRegSubmittedlabel =$A.get("$Label.c.PCC_DealRegSubmitted_Url");
        const dealRegDraftlabel =$A.get("$Label.c.PCC_DealRegDraft_Url");

        if(detail === false) {
            window.open(dealRegListViewlabel+dealRegDraftlabel,'_self');
        } else {
            window.open(dealRegListViewlabel+dealRegSubmittedlabel,'_self');
        }
    },
})