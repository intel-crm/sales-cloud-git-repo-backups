({
	// Function to Fetch all the Intel Accounts
	getAllIntelAccounts: function (component, event) {
		var action = component.get("c.getIntelAccountRecords");
		var recordId = component.get("v.recordId");

		action.setParams({
			recordId: recordId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			var allAccts = [];
			var selAccts = [];
			var selsorted = [];
			if (state === "SUCCESS") {
				//var result = response.getReturnValue();
				var mapofAllIntelAccountNameAndId = response.getReturnValue().accountsMap;
				var mapofAllSelectedAccountNameAndId = response.getReturnValue().selectedAccountsMap;
				var exceptionStatus = response.getReturnValue().statusStr;
				//Attributes to store status
				component.set("v.exceptionStatus", exceptionStatus);
				if (Object.keys(mapofAllIntelAccountNameAndId).length > 0) {
					for (var key in mapofAllIntelAccountNameAndId) {
						allAccts.push({
							label: mapofAllIntelAccountNameAndId[key],
							value: key
						});
					}
				}

				// Setting the selected accounts 
				if (Object.keys(mapofAllSelectedAccountNameAndId).length > 0) {
					for (var key in mapofAllSelectedAccountNameAndId) {
						selsorted.push({
							label: mapofAllSelectedAccountNameAndId[key],
							value: key
						});
					}
					if (selsorted.length > 0) {
						selsorted = this.sortArray(selsorted);
					}

					for (var key in selsorted) {
						selAccts.push(selsorted[key].value);
					}
				} else {
					component.set("v.loadExceptionsAccountLayout", true);
				}

				if (allAccts.length > 0) {
					allAccts = this.sortArray(allAccts);
				}

				//Attributes which holds all accounts and selected accounts
				component.set("v.AccountList", allAccts);
				//component.set("v.storeAccountList",allAccts);
				component.set("v.selectedAccountList", selAccts);
			}
		});
		$A.enqueueAction(action);
	},
	// Save the Selected Value
	saveAccounts: function (component, event) {
        var selectedValues = component.get("v.selectedAccountList");
        var allAccts = component.get("v.AccountList");
        var selectedLabel = '';
        for( var key in allAccts){
            var value = allAccts[key].value;
            if(selectedValues.indexOf(value) > -1){
                selectedLabel += allAccts[key].label + ';';
            }
        }
        selectedLabel.slice(0,-1);
		if (selectedValues.length > 0) {

			var action = component.get("c.saveExceptionAccountMappingRecords");
			var recordId = component.get("v.recordId");
			action.setParams({
				recordId: recordId,
				accountIdList: selectedValues,
				exceptionStatus: component.get("v.exceptionStatus"),
				addAccountCheck: component.get("v.exceptionsQucikActionIndicator"),
                strSelectedAccountNames: selectedLabel
			});

			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var result = response.getReturnValue();
					var errorMessage = response.getReturnValue().exceptionStatusError;
					var successCheck = response.getReturnValue().isSuccess;
					if (successCheck && errorMessage == '') {
						var toastEvent = $A.get("e.force:showToast");
						var msg = $A.get("$Label.c.Core_MDF_Account_Update_Success_Message");
						toastEvent.setParams({
							title: 'Success',
							type: 'success',
							message: msg
						});
						toastEvent.fire();

						var navEvt = $A.get("e.force:navigateToSObject");
						navEvt.setParams({
							"recordId": component.get('v.recordId'),
							"slideDevName": "detail"
						});
						navEvt.fire();

						setTimeout(function () {
							window.location.reload();
						}, 2000);

					} else {
						//component.set("v.loadExceptionsAccountLayout", false);
						//component.set("v.exceptionsQucikActionIndicator", false);
						component.set("v.exceptionsStatusErrorCheck", true);
						component.set("v.exceptionStatusErrorMessage", errorMessage);
					}
				}
			});

			$A.enqueueAction(action);

		} else {
			var msg = $A.get("$Label.c.Core_MDF_Excp_select_Acc_Error");
			//component.set("v.loadExceptionsAccountLayout", false);
			component.set("v.exceptionsStatusErrorCheck", true);
			component.set("v.exceptionStatusErrorMessage", msg);
		}
	},
	sortArray: function (arrayVal) {
		return arrayVal.sort((a, b) => a.label.localeCompare(b.label));
	}
})