window._snapinsSnippetSettingsFile = (function() {
   var userId = $A.get("$SObjectType.CurrentUser.Id");
  embedded_svc.snippetSettingsFile.extraPrechatFormDetails = [{
    "label":"First Name", 
    "transcriptFields": ["FirstName__c"],
	
  },{
    "label":"Last Name", 
    "transcriptFields": ["LastName__c"]
  },{
    "label":"Email", 
    "transcriptFields": ["Email__c"]
  },{
	"label":"LoggedInUserId", 
    "transcriptFields": ["LoggedInUserId__c"],
	"value": userId,
    "displayToAgent": false
  }];
})();