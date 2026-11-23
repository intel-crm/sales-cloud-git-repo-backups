public class SampleAuraController {
     
    @AuraEnabled
    public static List <String> getPiklistValues(Id accountId) {
        List<String> plValues = new List<String>();
        /*
        List<AccountUser> accUserList = [Select Id, account, user from accountUser where AccountId =: accountId]; 
        List<String> selectedUsrList;
        for(AccountUser a: accUserList){
            selectedUsrList.add(a.user);
        }
        List<User> userList = [select id from User where user.active= true AND Id NOT IN: selectedUsrList];
        List<String> availableUserList;
        for(User u: userList){
            availableUserList.add(u.Name);       
        }*/
        
        /* 
        //Get the object type from object name. Here I've used custom object Book.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Book__c');
         
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
         
        //Get the specific field information from field name. Here I've used custom field Genre__c of Book object.
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('Genre__c').getDescribe();
         
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
         
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }*/
        plValues.sort();
        return plValues;
    }
}