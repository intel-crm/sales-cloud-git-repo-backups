/*IPA2.0: US-TWC729-7976*/
public class PSS_SolutionContact_TriggerHelper {
    
   /*public static void shareSolutionToContact(List<PSS_Solution_Contact_Association__c> solConList){
        Set<Id> conIds = new Set<Id>();
        Set<Id> solutionIds = new Set<Id>();
        map<id,id> solContactMap = new map<id,id>();	
        
        List<ArdiraSurvey__Survey_Result__Share> solShareList = new List<ArdiraSurvey__Survey_Result__Share>();
        system.debug('the solution con==>'+solConList);
        if(!solConList.isempty()){
            for(PSS_Solution_Contact_Association__c solCon : solConList){
                conIds.add(solCon.PSS_Assigned_Contact__c);
                solutionIds.add(solCon.PSS_Solution_Name__c);
                solCon.PSS_Active__c = True;
                system.debug('contact id===>'+solCon.PSS_Assigned_Contact__c);
                system.debug('Solution id===>'+solCon.PSS_Solution_Name__c);
                solContactMap.put(solCon.PSS_Assigned_Contact__c, solCon.PSS_Solution_Name__c);
            }
        }
        
        system.debug('the map==>'+solContactMap);
        
        if(!conIds.isempty()){
        List<User> userList = [select id,contactId from user where contactId IN :conIds];
            system.debug('the user list size==>'+userList.size());
            for(user u: userList){
                ArdiraSurvey__Survey_Result__Share solShare = new ArdiraSurvey__Survey_Result__Share();
                        solShare.ParentId = solContactMap.get(u.contactId);
                        solShare.UserOrGroupId = u.id;
                        solShare.AccessLevel ='edit';
                        solShare.RowCause ='Manual';
                        solShareList.add(solShare);
            }
            
        }
        system.debug('the list size==>'+solShareList.size());
        if(!solShareList.isempty()){
            insert solShareList;
        }
    }*/

}