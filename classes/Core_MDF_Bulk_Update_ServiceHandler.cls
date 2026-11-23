/*********************************************************************************************************************************************************************************
* Class Name  : Core_MDF_RecallApprovalServiceHandler 
* Version     : 1.0 
* Created Date: 4-26-2021
* Modification Log :
* Developer                         Date                          Description
**********************************************************************************************************************************************************************************/
public without sharing class Core_MDF_Bulk_Update_ServiceHandler {
    
     public static String logEntryMsg = '';
     public static Integer maxSizeOfList = 10000;
     public static Integer strtLoop = 0;
     public static Integer endLoop = 20;
    
    /*****************************************************************************************************
Method Name :   updateRecords 
@return     :   NULL
@parameters :   list of Core_MDF_Bulk_Update__e platform event record
Description :   Perform Bulk Update
******************************************************************************************************/
    public static void updateRecords(List<Core_MDF_Bulk_Update__e> newList){
        
        List<Core_MDF_Bulk_Update__e> bulkUpdList = new List<Core_MDF_Bulk_Update__e>(newList);
       
        
      
        // List<PartnerFundClaim> pfcList= new List<PartnerFundClaim>();
        try{
            String objectName = newList[0].Core_MDF_Object_Name__c;
            String transactionType = newList[0].Core_MDF_Transaction_Type__c;
            List<Core_MDF_Bulk_Transaction_PlatformEvents__mdt> btpeList = new List<Core_MDF_Bulk_Transaction_PlatformEvents__mdt>();
            List<String> textFieldList = new List<String>();
            List<String> checkBoxFieldList = new List<String>();
            for(Core_MDF_Bulk_Transaction_PlatformEvents__mdt btpe : [SELECT id,Core_MDF_Check_Box_Field_API_Name__c,Core_MDF_Text_Field_API_Name__c,Core_MDF_Object_Name__c
                                                                      FROM Core_MDF_Bulk_Transaction_PlatformEvents__mdt
                                                                      WHERE Core_MDF_Object_Name__c = :objectName AND Core_MDF_Transaction_Type__c = :transactionType]){
                                                                          textFieldList = btpe.Core_MDF_Text_Field_API_Name__c.split(';');
                                                                          checkBoxFieldList = btpe.Core_MDF_Check_Box_Field_API_Name__c.split(';');                                                         
                                                                      }
            /* Call global describe to get the map of string to token. */
            Map<String, Schema.SObjectType> glblDesc = Schema.getGlobalDescribe(); 
            Schema.SObjectType sObjctTyp = glblDesc.get(objectName);
            String listType = 'List<' + objectName + '>';
            List<SObject> sObjList = (List<SObject>)Type.forName(listType).newInstance();
           
            //Schema.SObjectType st = gd.get(objectName);
            //Sobject s = st.newSobject();
            // Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PartnerFundClaim').getDescribe().fields.getMap();
            // Map<String, String> preDefinedMap = new Map<String, String>();
            //List<st>  sObjList = new List<st>();
            for(Core_MDF_Bulk_Update__e eventObj: newList){                 
                
                Sobject sObj = sObjctTyp.newSobject();
                Integer count = 1;
                for(String str : textFieldList){              
                    String apiNameEvt = 'Core_MDF_Field_'+count+'__c';
                    sObj.put(str, eventObj.get(apiNameEvt));
                    count++;
                }
                count = 1;
                for(String str : checkBoxFieldList){          
                    String apiNameEvt = 'Core_MDF_Check_Box_'+count+'__c'; 
                    sObj.put(str, eventObj.get(apiNameEvt));
                    count++;
                }
                sObjList.add(sObj);
            } 
            /*Loop and upload over 20 records each loop
            maxSizeOfList = newList.size();
            Boolean maxSizeIndicatr = (newList.size()>20)?true:false;
            if(!maxSizeIndicatr){
                endLoop =  maxSizeOfList;
            }
           
            do{
                List<SObject> sObjListForClaim = (List<SObject>)Type.forName(listType).newInstance();
                for(Integer i = strtLoop; i<10; i++){
                    sObjListForClaim.add(sObjList[i]); 
                }
            	if(sObjListForClaim != null && !sObjListForClaim.isEmpty() && sObjListForClaim.size()>0){
                     List<Database.SaveResult> results = Database.Update(sObjList); 
                     strtLoop = endLoop;
                     endLoop = endLoop+10;
            	} 
            }while(endLoop == maxSizeOfList);*/
            //Calling Bathc Class
           Core_MDF_Claim_Update.updateClaim(sObjList);
            
            //Bulk Upload
            /*System.debug('PC: '+sObjList);
            if(sObjList != null && !sObjList.isEmpty() && sObjList.size()>0){
                 List<Database.SaveResult> results = Database.Update(sObjList); 
               	
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        
                        System.debug('Successfully published event.');
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' + err.getStatusCode() );
                        }
                    }
                }
               
            }*/
          //  }while(bulkUpdList != null);
            /*List<SObject> sObjListBreak = (List<SObject>)Type.forName(listType).newInstance();
            if(sObjList.size()>20){
               		sObjListBreak.add 
            }*/
            
            
                        /* for(Core_MDF_Bulk_Update__e recallEventObj: newList){ 
            
            //objectName pfc= new objectName();
            //String 
            Sobject sObj = st.newSobject();
            pfc.Id = recallEventObj.Core_MDF_Target_Object_Id__c;
            pfc.Core_MDF_Audit_Type__c = recallEventObj.Core_MDF_Field_1__c;
            pfc.Core_MDF_FlaggedForAudit__c = recallEventObj.Core_MDF_Check_Box_1__c;
            pfc.Core_MDF_Status__c = recallEventObj.Core_MDF_Field_2__c;
            //pfc.Core_MDF_Audit_Hold__c = (Boolean)recallEventObj.Core_MDF_Field_3__c;
            pfcList.add(pfc);   
            // Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PartnerFundClaim').getDescribe().fields.getMap();
            // Map<String, String> preDefinedMap = new Map<String, String>();
            // for(Schema.SObjectField sfield : fieldMap.Values()){
            // String strType = string.valueOf(fieldMap.get(sfield.getdescribe().getname()).getDescribe().getType());
            // System.debug('NZ--Fields: '+sfield);
            // System.debug('NZ--Fields: '+new SelectOption(sfield.getdescribe().getname(), sfield.getdescribe().getlabel()));
            // options.add(new SelectOption(sfield.getdescribe().getname(), sfield.getdescribe().getlabel()));
            //}
            }*/
                        /* System.debug('PC: '+pfcList);
            if(pfcList != null && !pfcList.isEmpty() && pfcList.size()>0) {
            update pfcList;   
            }*/
            }catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Label.Core_MDF_Activity_Recall_Exception_Origin);         
                            }         
    }
    
}