/***************************************************************************************************
* Apex Class Name : Core_IPS_JSON_Utility
* Test Class Name : Core_IPS_JSON_UtilityTest
* Description : Convert base64 to document link and richtextarea image to base64
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan                  24/09/2020 
* UserStory:                   US789651/US501212
****************************************************************************************************/
public without sharing class Core_IPS_JSON_Utility {
/*
* 
* this method will use for rich text area data conversion to base64 if it contains any image in it. 
* Pass richtextarea field data if image containing in this it will return with base64 along with text.
* Eg. richTextAreaString = '<img alt="Test pic" src="https://intel--CRMDEVCASE--c.cs92.content.force.com/servlet/rtaImage?eid=5003F0000073N46&amp;feoid=00No000000Cwxp3&amp;refid=0EM3F0000005yDV"></img>test desc <br>';
*     
*/
    
    public static String getBase64ImgConvert(String richTextAreaString){
         List<String> finalStringList =new List<String>();
        try{
        if(String.isBlank(richTextAreaString)){
            return '';
        }
        Transient String s3= '';
        Transient String s2 = '';
        List<String> allimgString = richTextAreaString.split('<img ');
        System.debug(allimgString );
        List <String> allImageUrls = new List<String>(); 
        
        For(String str: allimgString ){
            String finalString = '';
            s2 = str.substringBetween('src="','"');
            system.debug('s2'+s2);
            if(String.IsBlank(s2)){
                finalString += str;
            }else{
                finalString = finalString + '<img ' + str;
            }
            If(!String.IsBlank(s2) && s2.startsWith('http') && s2.contains('servlet/rtaImage') && !s2.endsWithIgnoreCase('.jpg') ){
                s3=s2.replaceAll('amp;','');
                allImageUrls.add(s3);
                PageReference pageRef = new PageReference(String.escapeSingleQuotes(s3));
                String s ='';
                if(Test.isRunningTest()){
                    s = 'Unit.Test';
                }else{
                    s=EncodingUtil.base64Encode(pageRef.getContent());
                }
                finalString=FinalString.replace(s2,'data:image/jpeg;base64,'+s);
                
            }
            finalStringList.add(finalString); 
        }
        }catch(Exception e){

            Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c();
            /*US1038991 - 07/08/2021 - Vishal - FLS Check for security vulnerability --*/
            if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Description__c.isCreateable()) {
                errorLog.Core_IPS_Error_Description__c = e.getStackTraceString();
            }
            if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Status__c.isCreateable()) {
                errorLog.Core_IPS_Status__c = e.getMessage();
            }
            insert errorLog;
        
        }
        return String.join(finalStringList,'');
    }
}