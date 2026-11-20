/* --------------------------------------------------------------------------------------*
Modification Log :
* Developer                   Date                   Description
*---------------------------------------------------------------------------------------*
* Sushma Hamom              Dec-04-2018         Weezer: US233016 - Add logic to 
*                                               ignore CCP RecordTypes DevName:
*                                               Core_MDF_Aduit and Core_MDF_Audit_Closed
* ------------------------------------------------------------------------------------- */      
public class Core_CaseTriggerHandler {

  public static boolean triggerupdateCEPCaseRegionPickListValue = true;  

  /** commented for US265805
  
  public static Map<ID,Schema.RecordTypeInfo> rt_Map = Case.SObjectType.getDescribe().getRecordTypeInfosById();  //Added Weezer: US233016
  
  public static Map<String,String> ccprectypeMap = new Map<String, String>();                                   // Added Weezer: US233016
    
    public static void updateCEPCaseRegionPickListValue(List<Case> newList, Map<Id, Case> mapOldsObject)
    {         
        
        //** Start of change by Weezer: US233016 ***********     
        If(rt_Map <> null && rt_Map.size() > 0 && ( ccprectypeMap == null || ccprectypeMap.size() == 0) )
        {
            for(Schema.RecordTypeInfo rectypinfo: rt_Map.Values())
            {
                if(System.Label.Core_MDF_Case_RecTypes.contains(rectypinfo.getDeveloperName()))
                {
                    ccprectypeMap.put(rectypinfo.getRecordTypeId(),rectypinfo.getDeveloperName());
                }
            }
        }
        //** End of change by Weezer: US233016 *************     
        
        
        Set<Id> caseIds = new Set<Id>();
        
        try {
        
            if(triggerupdateCEPCaseRegionPickListValue)
            {
                triggerupdateCEPCaseRegionPickListValue = false;   //Make sure - trigger does not run multiple times
                for (Case c: newList) {
                  
                    if (Trigger.isInsert && ((ccprectypeMap == null) || ccprectypeMap.get(c.RecordTypeId) == null) ) //Added the ccprectypeMap check by Weezer: US233016
                    {
                        caseIds.add(c.ID);
                    }
                    else if(Trigger.isUpdate && ! mapOldsObject.get(c.Id).Core_CEP_Case_Region__c.equalsIgnoreCase(c.Core_CEP_Case_Region__c)  && ((ccprectypeMap == null) || ccprectypeMap.get(c.RecordTypeId) == null) )//Added the ccprectypeMap check by Weezer: US233016
                    {
                       caseIds.add(c.ID);
                    }
                }    
            
                //Outside for loop
                List<case> caseList = [select Id,Core_CEP_Account_Name__r.Core_Geo__c  from case where Id in :caseIds];
                
                for (Case ca : caseList) {
                    System.debug('##### obj.Id: ' + ca.Id);
                    //update picklist field name
                    ca.Core_CEP_Case_Region__c = ca.Core_CEP_Account_Name__r.Core_Geo__c;
                }
                
                if(!caseList.isEmpty())
                    update caseList;

                
                System.debug('Update CEP Case Region Picklist value for ' + caseList); 
            }

        }
        catch(Exception e){
            //If there is any exception, append it to the list of sobject records
            System.debug('Error occured Update CSM Picklist value for following accounts' + caseIds);
        }    

        System.debug('updateCEPCaseRegionPickListValue : END');        
    } 
    **/
  }