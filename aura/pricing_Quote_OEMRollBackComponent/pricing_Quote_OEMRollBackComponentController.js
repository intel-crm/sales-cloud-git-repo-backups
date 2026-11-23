({
	doInit: function (component, event, helper) {
  
	  // Set error message
	  component.set(
		"v.errorMsg",
		$A.get("$Label.c.Pricing_Tender_API_Quotelines_SVD_Recall_Error_Msg")
	  );
  
	  // Fetch quote details
	  const action = component.get("c.getQuoteDetails");
	  action.setParams({ recordId: component.get("v.recordId") });
  
	  action.setCallback(this, function (response) {
		const state = response.getState();
		if (state === "SUCCESS") {
		  let quote = response.getReturnValue();
  
		  if (
			quote.Pricing_Program_Type_Nm__c ===
			$A.get("$Label.c.Pricing_Tender_Small_Volume_Quote")
		  ) {
			// Fetch SVD Active Status
			const isSVDActiveAction = component.get("c.getSVDQuoteActiveStatus");
			isSVDActiveAction.setCallback(this, function (response) {
			  const svdState = response.getState();
			  if (svdState === "SUCCESS") {
				component.set("v.isSVDActive", response.getReturnValue());
			  } else if (svdState === "ERROR") {
				console.error("Error fetching SVD Active Status: ", response.getError());
			  }
			});
			$A.enqueueAction(isSVDActiveAction);
		  }
		  component.set("v.isLoad", true);
		} else if (state === "ERROR") {
		  console.error("Error fetching Quote Details: ", response.getError());
		}
	  });
  
	  $A.enqueueAction(action);
	},
  
	closeWindow: function (component, event, helper) {
	  $A.get("e.force:closeQuickAction").fire();
	  $A.get("e.force:refreshView").fire();
	}
  });