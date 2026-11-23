/****************************************************************************************************************************************
* Class Name  : PMP_CreateLanguageTranslations 
* Version     : 1.0 
* Created Date: 03-29-2019
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Sandeep K                       03-29-2019             To Create/Update/Delete Translation records only on change of Offering fields.
*****************************************************************************************************************************************/

public with sharing class PMP_CreateLanguageTranslations 
{
     public static Boolean isWorking() {
        return true;
    }
    //IPA2.0 offering changes
    /*
    public static void insertLanguageTranslation(PMP_Partner_Offering__c offering)
    {
        list<PMP_Partner_Offering_Translation__c> translationRecordList = new list<PMP_Partner_Offering_Translation__c>();   
        if(offering.PMP_Partner_Offering_Nm__c != null)
        {
            PMP_Partner_Offering_Translation__c lngeTrnsl = new PMP_Partner_Offering_Translation__c();
            lngeTrnsl.Name = offering.id+PMP_StaticConstants_Offering.Name;
            //lngeTrnsl.PMP_Object_Id__c = offering.id;
            //lngeTrnsl.PMP_Object_Type__c = 'PMP_Partner_Offering__c';
            lngeTrnsl.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Name; 
            lngeTrnsl.PMP_Partner_Offering_Id__c=offering.id;
            if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.English) 
                lngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Nm__c;                   
            else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Chinese) 
                lngeTrnsl.PMP_Chinese_Txt__c= offering.PMP_Partner_Offering_Nm__c;
            else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Japanese)
                lngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Nm__c;
            translationRecordList.add(lngeTrnsl);
        }
        if(offering.PMP_Partner_Offering_Tag_Line_Txt__c != null)
        {
            PMP_Partner_Offering_Translation__c lngeTrnsl = new PMP_Partner_Offering_Translation__c();
            lngeTrnsl.Name = offering.id+PMP_StaticConstants_Offering.Tag; 
            lngeTrnsl.PMP_Partner_Offering_Id__c=offering.id;
            //lngeTrnsl.PMP_Object_Id__c = offering.id;
            //lngeTrnsl.PMP_Object_Type__c = 'PMP_Partner_Offering__c';
            lngeTrnsl.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Tag; 
            if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.English) 
                lngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c ;                   
            else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Chinese) 
                lngeTrnsl.PMP_Chinese_Txt__c= offering.PMP_Partner_Offering_Tag_Line_Txt__c;
            else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Japanese)
                lngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c;
            translationRecordList.add(lngeTrnsl);
        }
        if(offering.PMP_Partner_Offering_Dsc__c != null)
        {
            PMP_Partner_Offering_Translation__c lngeTrnsl = new PMP_Partner_Offering_Translation__c();
            lngeTrnsl.Name = offering.id+PMP_StaticConstants_Offering.Description ; 
            lngeTrnsl.PMP_Partner_Offering_Id__c=offering.id;
            //lngeTrnsl.PMP_Object_Id__c = offering.id;
            //lngeTrnsl.PMP_Object_Type__c = 'PMP_Partner_Offering__c';
            lngeTrnsl.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Description ; 
            if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.English) 
                lngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Dsc__c;                   
            else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Chinese) 
                lngeTrnsl.PMP_Chinese_Txt__c= offering.PMP_Partner_Offering_Dsc__c;
            else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Japanese)
                lngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Dsc__c;
            translationRecordList.add(lngeTrnsl);
        }
        try{
            if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isCreateable()){
            	insert translationRecordList;
            }    
        }
        catch(Exception e){
            //System.debug('Exception while inserting Translation records '+e+' at line:'+e.getlinenumber());
            PMP_Utility.logError(e,'PMP_OfferingTranslations');
        }
    }
    
    
    public static void updateLanguageTranslation(PMP_Partner_Offering__c offering)
    {       
        list<PMP_Partner_Offering_Translation__c> existingTransRecords = new list<PMP_Partner_Offering_Translation__c>();
        list<PMP_Partner_Offering_Translation__c> updateTransactionRecords  = new list<PMP_Partner_Offering_Translation__c>();
        if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){
        	existingTransRecords = [select id, Name, PMP_Field_Nm__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =: offering.id];
        }
        try
        {
            if(existingTransRecords.size() > 0)
            {
                for(PMP_Partner_Offering_Translation__c updlngeTrnsl : existingTransRecords)
                {
                    boolean changed = false;
                    //If the Offering Language is English, Check English Fields for Title, Description and Tag Line
                    if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.English)
                    {
                        
                        if(updlngeTrnsl.PMP_Field_Nm__c == PMP_StaticConstants_Offering.Name && (updlngeTrnsl.PMP_English_Txt__c == null || updlngeTrnsl.PMP_English_Txt__c != offering.PMP_Partner_Offering_Nm__c))
                        {                   
                            updlngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Nm__c;
                            changed = true;
                        }                   
                        else if(updlngeTrnsl.PMP_Field_Nm__c == PMP_StaticConstants_Offering.Description  && (updlngeTrnsl.PMP_English_Txt__c == null || updlngeTrnsl.PMP_English_Txt__c != offering.PMP_Partner_Offering_Dsc__c))
                        {                  
                            updlngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Dsc__c;
                            changed = true;
                        }
                        else if(updlngeTrnsl.PMP_Field_Nm__c == PMP_StaticConstants_Offering.Tag && offering.PMP_Partner_Offering_Tag_Line_Txt__c != null && (updlngeTrnsl.PMP_English_Txt__c == null || updlngeTrnsl.PMP_English_Txt__c != offering.PMP_Partner_Offering_Tag_Line_Txt__c))
                        {                  
                            updlngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c ;
                            changed = true;
                        }
                        if(changed == true)
                        {
                            updlngeTrnsl.PMP_Chinese_Txt__c = '';
                            updlngeTrnsl.PMP_Japanese_Txt__c = '';                        
                        }  
                    }
                    
                    //If the Offering Language is Chinese, Check Chinese Fields for Title, Description and Tag Line
                    else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Chinese)
                    {                                                        
                        if(updlngeTrnsl.PMP_Field_Nm__c == PMP_StaticConstants_Offering.Name && (updlngeTrnsl.PMP_Chinese_Txt__c == null || updlngeTrnsl.PMP_Chinese_Txt__c != offering.PMP_Partner_Offering_Nm__c))
                        {                   
                            updlngeTrnsl.PMP_Chinese_Txt__c = offering.PMP_Partner_Offering_Nm__c;
                            changed = true;
                        }                   
                        else if(updlngeTrnsl.PMP_Field_Nm__c == PMP_StaticConstants_Offering.Description  && (updlngeTrnsl.PMP_Chinese_Txt__c == null || updlngeTrnsl.PMP_Chinese_Txt__c != offering.PMP_Partner_Offering_Dsc__c))
                        {                  
                            updlngeTrnsl.PMP_Chinese_Txt__c = offering.PMP_Partner_Offering_Dsc__c;
                            changed = true;
                        }
                        else if(updlngeTrnsl.PMP_Field_Nm__c == PMP_StaticConstants_Offering.Tag && offering.PMP_Partner_Offering_Tag_Line_Txt__c != null && (updlngeTrnsl.PMP_Chinese_Txt__c == null || updlngeTrnsl.PMP_Chinese_Txt__c != offering.PMP_Partner_Offering_Tag_Line_Txt__c))
                        {                  
                            updlngeTrnsl.PMP_Chinese_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c ;
                            changed = true;
                        }
                        if(changed == true)
                        {
                            updlngeTrnsl.PMP_English_Txt__c = '';
                            updlngeTrnsl.PMP_Japanese_Txt__c = '';                           
                        }  
                    }
                    
                    //If the Offering Language is Japanses, Check Japanese Fields for Title, Description and Tag Line
                    else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Japanese)
                    {                                                         
                        if(updlngeTrnsl.PMP_Field_Nm__c == PMP_StaticConstants_Offering.Name && (updlngeTrnsl.PMP_Japanese_Txt__c == null || updlngeTrnsl.PMP_Japanese_Txt__c != offering.PMP_Partner_Offering_Nm__c))
                        {                   
                            updlngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Nm__c;
                            changed = true;
                        }                   
                        else if(updlngeTrnsl.PMP_Field_Nm__c == PMP_StaticConstants_Offering.Description  && (updlngeTrnsl.PMP_Japanese_Txt__c == null || updlngeTrnsl.PMP_Japanese_Txt__c != offering.PMP_Partner_Offering_Dsc__c))
                        {                  
                            updlngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Dsc__c;
                            changed = true;
                        }
                        else if(updlngeTrnsl.PMP_Field_Nm__c == PMP_StaticConstants_Offering.Tag && offering.PMP_Partner_Offering_Tag_Line_Txt__c != null && (updlngeTrnsl.PMP_Japanese_Txt__c == null || updlngeTrnsl.PMP_Japanese_Txt__c != offering.PMP_Partner_Offering_Tag_Line_Txt__c))
                        {                  
                            updlngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c ;
                            changed = true;
                        }
                        if(changed == true)
                        {
                            updlngeTrnsl.PMP_English_Txt__c = '';
                            updlngeTrnsl.PMP_Chinese_Txt__c = '';                           
                        }  
                    }
                    if(updlngeTrnsl.Name != offering.PMP_Partner_Offering_Nm__c)
                    {
                        
                        //updlngeTrnsl.Name = offering.id+PMP_StaticConstants_Offering.Name;
                        changed = true;                   
                    }                   
                    // system.debug('changed ==>'+changed);
                    
                    if(changed == true){
                        //update updlngeTrnsl; //commented by Gireesh
                        //US614314:Gireesh
                        updateTransactionRecords.add(updlngeTrnsl);
                            }
                    
                    //system.debug('updateTransactionRecords==>'+updlngeTrnsl);                 
                }
                if(updateTransactionRecords.size()>0 && Schema.sObjectType.PMP_Partner_Offering_Translation__c.isUpdateable()){
                    update updateTransactionRecords;
                }
            }
            else if(existingTransRecords.size() == 0)
            {
                PMP_CreateLanguageTranslations.insertLanguageTranslation(offering);
            }
            if(offering.PMP_Partner_Offering_Tag_Line_Txt__c == null && existingTransRecords.size() == 3 && Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()) 
            {
                delete [select id, Name, PMP_Field_Nm__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =: offering.id and PMP_Field_Nm__c =: PMP_StaticConstants_Offering.Tag ];
            }
            if(offering.PMP_Partner_Offering_Tag_Line_Txt__c != null && existingTransRecords.size() == 2)
            {
                PMP_Partner_Offering_Translation__c lngeTrnsl = new PMP_Partner_Offering_Translation__c();
                lngeTrnsl.Name = offering.id+PMP_StaticConstants_Offering.Tag ;
                lngeTrnsl.PMP_Partner_Offering_Id__c=offering.id;
                //lngeTrnsl.PMP_Object_Id__c = offering.id;
                //lngeTrnsl.PMP_Object_Type__c = 'PMP_Partner_Offering__c';
                lngeTrnsl.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Tag ; 
                if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.English) 
                    lngeTrnsl.PMP_English_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c;                   
                else if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Chinese) 
                    lngeTrnsl.PMP_Chinese_Txt__c= offering.PMP_Partner_Offering_Tag_Line_Txt__c;
                else  if(offering.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Japanese)
                    lngeTrnsl.PMP_Japanese_Txt__c = offering.PMP_Partner_Offering_Tag_Line_Txt__c;
                
                if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isCreateable()){
                	insert lngeTrnsl;
                }    
            }
            // system.debug('no error');
        }
        catch(Exception e){
            //System.debug('Exception while updating Translation records '+e+' at line:'+e.getlinenumber());
            PMP_Utility.logError(e,'PMP_OfferingTranslations');
        }
    } 
*/
}