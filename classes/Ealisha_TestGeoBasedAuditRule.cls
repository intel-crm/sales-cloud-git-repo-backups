public class Ealisha_TestGeoBasedAuditRule {
    
       /*public static Map<String,Map<String,Boolean>> getGeoBasedAuditRule(){

    Map<String,Map<String,Boolean>> geoBasedAuditPerProgram = new Map<String,Map<String,Boolean>>();
    
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select DeveloperName,Core_MDF_GeoBasedAuditEnabled__c,Core_MDF_Channel_Program_txt__c from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
            Map<String,Boolean> labelToIndMap = new Map<String,Boolean>();                                                               
            labelToIndMap.put(recTypeMetaData.DeveloperName,recTypeMetaData.Core_MDF_GeoBasedAuditEnabled__c);
            geoBasedAuditPerProgram.put(recTypeMetaData.Core_MDF_Channel_Program_txt__c,labelToIndMap);
        }
        system.debug('geoBasedAuditPerProgram - '+geoBasedAuditPerProgram);
        return geoBasedAuditPerProgram;
        }

    public static Map<String,String> getCountryGeoMapping(){
        
Map<String,String> countryGeoMapping =new Map<String,String>();        
         //get the country geo mapping metadata.
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeo : [SELECT MasterLabel,Core_MDF_Geo__c,Core_MDF_Sub_Geo__c from Core_MDF_CCP_Country_Geo_Mapping__mdt])
            {
                if(countryGeo.Core_MDF_Geo__c == 'ASMO')
                {
                //    system.debug('geo is asmo for:'+countryGeo.MasterLabel);
                    countryGeoMapping.put(countryGeo.MasterLabel, countryGeo.Core_MDF_Sub_Geo__c);
                }
                else
                {
                    countryGeoMapping.put(countryGeo.MasterLabel, countryGeo.Core_MDF_Geo__c);
                }
            }
            return countryGeoMapping;
    }     

    public static void randomAuditSelectionModified(List<PartnerFundClaim> pfcList){ 
        
       //Variable declarations
        Integer rand;
        boolean isExceptionOccured  = false;
        Map<PartnerFundClaim,String> pfcMap = new Map<PartnerFundClaim,String>{};
        Map<String,Map<PartnerFundClaim,String>> returnList = new Map<String,Map<PartnerFundClaim,String>>{};
        Core_MDF_CCP_Claim_Window__mdt claimData = new Core_MDF_CCP_Claim_Window__mdt();
        Map<String,Map<String,Core_MDF_CCP_Claim_Window__mdt>> claimWindowMap = new Map<String,Map<String,Core_MDF_CCP_Claim_Window__mdt>>();        
        Map<String,Core_MDF_CCP_Claim_Window__mdt> existingProgData = new Map<String,Core_MDF_CCP_Claim_Window__mdt>();
        Map<String,String> countryGeoMapping = getCountryGeoMapping();
        Map<String,Map<String,Boolean>> geoBasedAuditPerProgram = getGeoBasedAuditRule();
        
 //get the target percentage,enable random audit flag,random audit baseline number fields program wise from the metadata.
 for(Core_MDF_CCP_Claim_Window__mdt claimWindow : [SELECT Id,DeveloperName, toLabel(Core_MDF_Program__c), Core_MDF_Enable_Random_Audit__c, Core_MDF_Amount__c, 
                                                          Core_MDF_Baseline_Random_Number__c, Core_MDF_Target_Percentage__c 
                                                          FROM Core_MDF_CCP_Claim_Window__mdt WHERE Core_MDF_Program__c LIKE '%Co-Marketing%' LIMIT 10000]){
                                                              if(claimWindowMap != null){
                                                                  existingProgData = claimWindowMap.get(claimWindow.Core_MDF_Program__c);
                                                                  if(existingProgData!=null)
                                                                  {
                                                                      existingProgData.put(claimWindow.DeveloperName,claimWindow);
                                                                  }
                                                                  else
                                                                  {
                                                                      existingProgData=new Map<String,Core_MDF_CCP_Claim_Window__mdt>();
                                                                      existingProgData.put(claimWindow.DeveloperName,claimWindow);
                                                                  }
                                                                  claimWindowMap.put(claimWindow.Core_MDF_Program__c, existingProgData);
                                                              }
                                                              else{
                                                                  existingProgData.put(claimWindow.DeveloperName,claimWindow);
                                                                  claimWindowMap.put(claimWindow.Core_MDF_Program__c, existingProgData);
                                                              }
                                                              
                                                          } 
system.debug('claimWindowMap:'+claimWindowMap); 

       
            String claimWindowName;
        string geo;
        string labelToIndMapKeySet;
            //itearate though the list of Claims.
            for(PartnerFundClaim clm: pfcList){
                if(geoBasedAuditPerProgram.containsKey('Client Co-Marketing Fund') && claimWindowMap.containsKey('Client Co-Marketing Fund')){
                    //get the target percentage,enable random audit flag,random audit baseline number and the amount field based on Claim's program.
                    Map<String,Boolean> labelToIndMap = geoBasedAuditPerProgram.get('Client Co-Marketing Fund');
                    system.debug('labelToIndMap:'+labelToIndMap+' '+labelToIndMap.values()[0]);
                    labelToIndMapKeySet = String.valueOf(labelToIndMap.keySet());
                    if(labelToIndMap.values()[0])                   
                    {
                        if(countryGeoMapping.containsKey(clm.Core_MDF_Country_Location_nm__c)){
                                 geo = countryGeoMapping.get(clm.Core_MDF_Country_Location_nm__c);
                             }
                        claimWindowName ='Core_MDF_'+(labelToIndMapKeySet.replace('{', '')).replace('}', '').trim()+'_'+geo+'_Claim_Window';
                    }
                    else
                    {
                        
                        claimWindowName = 'Core_MDF_'+(labelToIndMapKeySet.replace('{', '')).replace('}', '').trim()+'_Claim_Window';
                    }
                    system.debug('claimWindowName:'+claimWindowName);
                    Map<String,Core_MDF_CCP_Claim_Window__mdt> claimData1 = claimWindowMap.get('Client Co-Marketing Fund');
                    system.debug('claimData1:'+claimData1);
                    Core_MDF_CCP_Claim_Window__mdt claimDatax = claimData1.get(claimWindowName);
                    system.debug('claimDatax:'+claimDatax);
                    // for(Core_MDF_CCP_Claim_Window__mdt x:claimData1){
                    //     if(x.DeveloperName=claimWindowName){
                    //         claimData=x;
                    //     }
                    // } 
                    //system.debug('claimData:'+claimData);
                }
            }
    }
    
   */ 
}