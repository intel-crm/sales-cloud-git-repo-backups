/*trigger Core_Opp_Decision_Date_Trigger on Opportunity (before update) {  
    
      String getSOQL(String objectName) {

    // * Getting the field names using the object name
    Set<String> fieldNames = getSObjectFields(objectName);
        // * Forming the SOQL query
    String query = 'SELECT ';
    for(String fieldName : fieldNames) {
        query += fieldName + ', ';
    }
        // * Removing last , from the SOQL query string
    query = query.substring(0, query.lastIndexof(','));
        // * Adding the object name to the SOQL
    query += ' FROM ' + objectName;
        // * Returning the SOQL
    return query;
}
    Opportunity NewOpp = trigger.new;
    Opportunity OldOpp = trigger.old;
    system.debug('NewOpp ' + NewOpp);
    system.debug('OldOpp ' + OldOpp);
    List<String> Fields_API_List = System.Label.Core_Locked_Fields_API_Name.split(',');
    system.debug('Fields_API_List ' + Fields_API_List);
    
 
    
  /*  String itemQuery = 'SELECT Id, Core_Approval_Status__c' + System.Label.Core_Locked_Fields_API_Name + ' ' + 
            'FROM Opportunity ' + 
            'WHERE Id = \'' + trigger.new[0].Id + '\''; 
        System.debug(' itemQuery: ' + itemQuery);   
    
    Opportunity OppRec = Database.query(itemQuery);
    
    if(OppRec.Core_Approval_Status__c == 'Approved'){
        
    }
    */
    
   /*if(trigger.isInsert || trigger.isUpdate){
        
        if(trigger.old[0].IsWon != True && trigger.new[0].IsWon == True){
            System.debug('trigger.new[0].CloseDate ' + trigger.new[0].CloseDate);
            System.debug('trigger.old[0].CloseDate ' + trigger.old[0].CloseDate);
            
            trigger.new[0].CloseDate = trigger.old[0].CloseDate;
        }
      
   }   */
        
        
        
        
  /*      if(trigger.new[0].Core_Approval_Status__c == 'Approved' && trigger.old[0].Core_Approval_Status__c == 'Approved'){
            for(String str : Fields_API_List){
                if(trigger.old[0].str != trigger.new[0].str){
                    
                }
            }
            
            
        }
   
    for(Opportunity OppNew : trigger.new){
        if(OppNew.Core_Approval_Status__c == 'Approved' && OppNew.Name != trigger.old[0].Name){
            OppNew.addError('error');
        }
       }
    
   

}*/



trigger Core_Opp_Locked_Fields_On_Approval on Opportunity (after update, before update) {
/*
Opportunity NewOpp1 = trigger.new[0];

Opportunity OldOpp1 = trigger.old[0];

Opportunity OpportunityObject = new Opportunity(); // This takes all available fields from the required object.
   
  /*  if(NewOpp1.Core_Approval_Status__c == 'Approved' && OldOpp1.Core_Approval_Status__c == 'Approved'){

        Schema.SObjectType objType = OpportunityObject.getSObjectType();
Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
    
     List<String> Fields_API_List = System.Label.Core_Locked_Fields_API_Name.split(',');
    system.debug('Fields_API_List ' + Fields_API_List);

        for (String str : Fields_API_List) {

try {
System.debug('Field name: '+str +'. New value: ' + NewOpp1.get(str) +'. Old value: '+OldOpp1.get(str));

if(NewOpp1.get(str) != OldOpp1.get(str)){
NewOpp1.addError('error occur');
system.debug('*The value has changed!'); // here goes more code
}
}
catch (Exception e)
{
System.debug('Error: ' + e);
}
}
    }*/
    
  /*  if((NewOpp1.StageName == 'Design Win' && OldOpp1.StageName == 'Design Win')||
       (NewOpp1.StageName == 'Production Win' && OldOpp1.StageName == 'Production Win')||
       (NewOpp1.StageName == 'Lost' && OldOpp1.StageName == 'Lost')||
       (NewOpp1.StageName == 'Cancelled' && OldOpp1.StageName == 'Cancelled')||
       (NewOpp1.StageName == 'Production Lost' && OldOpp1.StageName == 'Production Lost')||
       (NewOpp1.StageName == 'Production Cancelled' && OldOpp1.StageName == 'Production Cancelled')||
       (NewOpp1.StageName == 'Group Cancelled' && OldOpp1.StageName == 'Group Cancelled')||
       (NewOpp1.StageName == 'Group Closed' && OldOpp1.StageName == 'Group Closed')){

        Schema.SObjectType objType = OpportunityObject.getSObjectType();
Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
    
     List<String> Fields_API_List1 = System.Label.Core_CoE_Status_Locked.split(',');
    system.debug('Fields_API_List ' + Fields_API_List1);

        for (String str1 : Fields_API_List1) {

try {
System.debug('Field name: '+str1 +'. New value: ' + NewOpp1.get(str1) +'. Old value: '+OldOpp1.get(str1));

if(NewOpp1.get(str1) != OldOpp1.get(str1)){
NewOpp1.addError('error occur');
system.debug('*The value has changed!'); // here goes more code
}
}
catch (Exception e)
{
System.debug('Error: ' + e);
}
}
    }*/
}