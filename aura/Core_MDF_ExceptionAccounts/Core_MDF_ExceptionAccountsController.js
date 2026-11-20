({
    doInit: function (component, event, helper) {
        /*component.set("v.loadExceptionsAccountLayout", false);
        component.set("v.exceptionsQucikActionIndicator", false);*/
        helper.getAllIntelAccounts(component, event);
    },
    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        /*var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Core_MDF_Exception__c"
        });
        homeEvent.fire();*/
    },

    saveAccounts: function (component, event, helper) {
        helper.saveAccounts(component, event);
    },
    onkeychange: function (component, event, helper) {
        var accList = component.get("v.AccountList");
        var skey = component.get("v.key").toLowerCase();
        var searchvalues = [];
        var nonsearchvalues = [];
        var filteredvalues = [];

        if (skey.length > 0) {
            for (var key in accList) {
                var originalValue = accList[key].value;
                var originalLabel = accList[key].label;
                var value = accList[key].label.toString().toLowerCase();
                if (value.indexOf(skey) > -1) {
                    searchvalues.push({
                        label: originalLabel,
                        value: originalValue
                    });
                } else {
                    nonsearchvalues.push({
                        label: originalLabel,
                        value: originalValue
                    });
                }
            }

            if (searchvalues.length > 0) {
                searchvalues = helper.sortArray(searchvalues);;
            }
            if (nonsearchvalues.length > 0) {
                nonsearchvalues = helper.sortArray(nonsearchvalues);;
            }

            filteredvalues = searchvalues.concat(nonsearchvalues);
        } else {
            for (var key in accList) {
                searchvalues.push({
                    label: accList[key].label,
                    value: accList[key].value
                });
            }
            filteredvalues = [];
            if (searchvalues.length > 0) {
                filteredvalues = helper.sortArray(searchvalues);
            }
        }

        component.set("v.AccountList", filteredvalues);
    },
    onselect: function (component, event, helper) {
        var allAccts = component.get("v.allaccts");
        var accList = component.get("v.AccountList");
        var searchvalues = [];

        if (allAccts) {
            if (accList.length > 0) {
                accList = helper.sortArray(accList);
            }
            for (var key in accList) {
                searchvalues.push(accList[key].value);
            }
            accList = [];
            component.set("v.selectedAccountList", searchvalues);
        } else {
            component.set("v.selectedAccountList", []);
        }
    }
})