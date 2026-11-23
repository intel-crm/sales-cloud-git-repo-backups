/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_ParseAllFilesJSONDelta
* Created Date: 31/12/2021 
* Modification Log :
* Developer       					Version                    			Date                    			Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Yashasvi Aggarwal        1.0    						 31/12/2021           				Created for Parsing the All Files Delta JSON and updating Specification Value Records
******************************************************************************************************************************************************************************************************/
public with sharing class PMP_ParseAllFilesJSONDelta {
    
    public static void parseAllFilesJSONDelta(String staticResourceName){
        List<String> specValuePIMIds = new  List<String>();
        List<PMP_Specification_Value__c> updatedSpecValuesList = new  List<PMP_Specification_Value__c>();
        final String staticResourceTestFileName = 'PMP_Delta_IPA_Products_Test';//test static resource for Delta file
        String[] jsonFileLines = new String[]{};
            String jsonStr;                                 //to store JSON file as string
        
        //fetch the JSON Delta file stored in Static Resource and processing it as string
        if(Test.isRunningTest()){  
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name =: staticResourceTestFileName];
            jsonStr = staticResourceFile.body.toString();
        }
        else{
            StaticResource staticResourceFile = [select id,body from StaticResource Where Name = :staticResourceName];
            jsonStr = staticResourceFile.body.toString();
        }
        try{
            jsonFileLines = jsonStr.split('\n'); 
            for(Integer i=1;i<jsonFileLines.size();i++){  
                if(jsonFileLines[i].contains('VPH_L4'))
                {
                    String[] jsonFileLinesValues = jsonFileLines[i].split('"');
                    if(jsonFileLinesValues[11]=='Launched')
                    {
                        specValuePIMIds.add(jsonFileLinesValues[3]);
                    }          
                }            
            }
            //System.debug('specValuePIMIds'+specValuePIMIds);
            //System.debug('specValuePIMIds Size'+specValuePIMIds.size());
            if(specValuePIMIds.size()>0)
            {
                List<PMP_Specification_Value__c> specValuesList = [Select Id,PMP_Product_Specification_Value_Key__c,PMP_Product_Status__c,PMP_Product_Restriction_Lvl__c
                                                                   from PMP_Specification_Value__c where PMP_Product_Specification_Value_Key__c in :specValuePIMIds];
                //System.debug('specValuesList'+specValuesList);
                for(PMP_Specification_Value__c specValueRecord:specValuesList)
                {
                    specValueRecord.PMP_Product_Status__c='Launched';   // setting the product status Launched
                    specValueRecord.PMP_Product_Restriction_Lvl__c='0'; // setting the restriction level 0
                    updatedSpecValuesList.add(specValueRecord);
                }
                if(updatedSpecValuesList.size()>0)
                {  
                    update updatedSpecValuesList;
                }
                //IPA2.0 - As part of TWC729-7977 commented the reference of publishFutureUpdateOfferings
                //Calling the batch class to publish and republish the offerings
                /*PMP_PublishFutureUpdateOfferings publishFutureUpdateOfferings = new PMP_PublishFutureUpdateOfferings();   
                Database.executebatch(publishFutureUpdateOfferings,1); */
            }
        }
        catch(Exception error){
            PMP_Utility.logError(error,'PMP_ParseAllFilesJSONDelta'); //log the error if any issues in the method.
        }     
    }
}