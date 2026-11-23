({
    /*afterRender: function (component, event, helper) {
        alert('in afterRender ');
        //helper.saveRecord(component);
        console.log('SUCCESS before', component.find("caseRec"));
        component.find("caseRec").saveRecord(function(saveResult) {
                console.log('SUCCESS before');
            // use the recordUpdated event handler to handle generic logic when record is changed
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log('SUCCESS ');
                // handle component related logic in event handler
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        });
    }*/
})