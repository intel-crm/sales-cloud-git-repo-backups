/****************************************************************************************************
Apex Class Name : PSG_ActiveProductExtAttrHandler
Version         : 1.0 
Created Date    : 08/30/2021
Function        : This class is used used as part of Product trigger for all the PSG functionalities
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya D                    08/30/2021               Created
*****************************************************************************************************/
public class PSG_ActiveProductExtAttrHandler {
    
    /************************************************************************************************************
	*Method Name : updateExtAttributesOnActiveProduct
	*Created Date: 08/30/2021
	*Author: Sandhya D 
	*Description : Updates Core_Product_Ext_Attribute__c records.
	************************************************************************************************************/
    /*public static void updateExtAttributesOnActiveProduct(List<Product2> newList,Map<Id,Product2> oldMap){
        system.debug('Inside EXT ATTR class');
        List<Product2> releaseProdList=new List<Product2>();
        Set<String> opnSet=new Set<String>();
        Map<String,Product2> opnProdMap=new Map<String,Product2>();
        Map<String,List<Core_Product_Ext_Attribute__c>> existingPreReleaseExtAttrMap=new Map<String,List<Core_Product_Ext_Attribute__c>>();
        List<Core_Product_Ext_Attribute__c> extAttrListToInsert=new List<Core_Product_Ext_Attribute__c>();
        String prodClassLabelVal = System.Label.PSG_Product_Class_Values;
        List<String> productClassVal = prodClassLabelVal.split(';');
        Map<String,String> prodHierarchyMDMap = new Map<String,String>();
        
        if(newList != null && prodHierarchyMDMap!= null){
            for(Product2 prod : newList){ 
               
                if(productClassVal.contains(prod.Core_Item_Class_Nm__c) && oldMap.get(prod.Id).isActive != prod.isActive && prod.isActive && prod.Core_Hierarchy_ID__c =='43' && prod.Core_Product_Org__c=='Sales' ){
                    releaseProdList.add(prod);
                    opnSet.add(prod.core_OPN__c);
                    system.debug('opnSet--'+opnSet);
                   
                }
            }               
        }
        if(!opnSet.isEmpty()){
            for(Product2 prodRec : [Select id,Name,core_OPN__c,Core_Product_Id__c,Core_Item_Class_Nm__c from Product2 where core_OPN__c IN :opnSet and Core_Hierarchy_ID__c = '59' and Core_Product_Org__c='Sales' and Core_Item_Class_Nm__c IN:productClassVal ORDER BY CreatedDate DESC LIMIT 1]){//FPGA Prod type = SV,BD,IC
              opnProdMap.put(prodRec.core_OPN__c,prodRec);
              system.debug('opnProdMap--'+opnProdMap);
            }
        }
        
        if(!opnProdMap.isEmpty()){ 
            List<Product2> extendedAttributeList = opnProdMap.values();
            for(Core_Product_Ext_Attribute__c preReleaseExtAttr: [select Id,Core_Product_Id__c,Core_SW_Prod_Additional_Dsc__c,Core_Prod_QTE_Alt_LGSTS_NW_Enabled_Ind__c,Core_SW_Lic_Authorization_Cd__c,Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c,Core_SW_Lic_Companion_Ind__c,
                                                                  Core_SW_Lic_File_Data_Encryption_Std_Cd__c,Core_SW_Lic_Enforcement_Method_Nm__c,Core_Foundation_Product_Id__c,Core_SW_Lic_Comment_Txt__c,Core_SW_Lic_Group_Id__c,Core_SW_Lic_Generator_Parameter_Txt__c,
                                                                  Core_SW_Lic_Linux_Download_URL_Txt__c,Core_SW_Prod_Max_Rehost_Cnt__c,Core_SW_Prod_Non_Commercial_Purpose_Nm__c,Core_SW_Prod_Expiration_Duration_Nbr__c,
                                                                  Core_SW_Lic_Rehostable_Ind__c,Core_SW_Lic_Renewal_Period_Nbr__c,Core_Prod_QTE_Slow_Moving_Inventory_Ind__c,Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Core_SW_Lic_Type_Nm__c,Core_Prod_Tool_Type_Nm__c,
                                                                  Core_SW_Prod_Web_Dsc__c,Core_SW_Lic_Web_Displayable_Ind__c,Core_SW_Lic_Windows_Download_URL_Txt__c 
                                                                  from Core_Product_Ext_Attribute__c where Core_Product_Id__c in:extendedAttributeList]){
            List<Core_Product_Ext_Attribute__c> preReleaseExtAttrList=existingPreReleaseExtAttrMap.containsKey(preReleaseExtAttr.Core_Product_Id__c)?existingPreReleaseExtAttrMap.get(preReleaseExtAttr.Core_Product_Id__c):new List<Core_Product_Ext_Attribute__c>();
            preReleaseExtAttrList.add(preReleaseExtAttr);
            existingPreReleaseExtAttrMap.put(preReleaseExtAttr.Core_Product_Id__c,preReleaseExtAttrList); 
                system.debug('existingPreReleaseExtAttrMap--'+existingPreReleaseExtAttrMap);                                                       
            }
        }
        
        
        for(Product2 prod:releaseProdList){ 
            if(opnProdMap.containsKey(prod.Core_OPN__c) && existingPreReleaseExtAttrMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){
                
                for(Core_Product_Ext_Attribute__c prodExtAttrAct:existingPreReleaseExtAttrMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){
                    
                    Core_Product_Ext_Attribute__c extAttrToInsert = new Core_Product_Ext_Attribute__c();
                    extAttrToInsert.Core_Product_Id__c =prod.Id;
                    extAttrToInsert.Core_SW_Prod_Additional_Dsc__c=prodExtAttrAct.Core_SW_Prod_Additional_Dsc__c;
                    extAttrToInsert.Core_Prod_QTE_Alt_LGSTS_NW_Enabled_Ind__c=prodExtAttrAct.Core_Prod_QTE_Alt_LGSTS_NW_Enabled_Ind__c;
                    extAttrToInsert.Core_SW_Lic_Authorization_Cd__c=prodExtAttrAct.Core_SW_Lic_Authorization_Cd__c;
                    extAttrToInsert.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c=prodExtAttrAct.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c;
                    extAttrToInsert.Core_SW_Lic_Companion_Ind__c=prodExtAttrAct.Core_SW_Lic_Companion_Ind__c;
                    extAttrToInsert.Core_SW_Lic_File_Data_Encryption_Std_Cd__c=prodExtAttrAct.Core_SW_Lic_File_Data_Encryption_Std_Cd__c;
                    extAttrToInsert.Core_SW_Lic_Enforcement_Method_Nm__c=prodExtAttrAct.Core_SW_Lic_Enforcement_Method_Nm__c;
                    extAttrToInsert.Core_SW_Lic_Comment_Txt__c=prodExtAttrAct.Core_SW_Lic_Comment_Txt__c;
                    extAttrToInsert.Core_SW_Lic_Group_Id__c=prodExtAttrAct.Core_SW_Lic_Group_Id__c;
                    extAttrToInsert.Core_SW_Lic_Generator_Parameter_Txt__c=prodExtAttrAct.Core_SW_Lic_Generator_Parameter_Txt__c;
                    extAttrToInsert.Core_SW_Lic_Linux_Download_URL_Txt__c=prodExtAttrAct.Core_SW_Lic_Linux_Download_URL_Txt__c;
                    extAttrToInsert.Core_SW_Prod_Max_Rehost_Cnt__c=prodExtAttrAct.Core_SW_Prod_Max_Rehost_Cnt__c;
                    extAttrToInsert.Core_SW_Prod_Non_Commercial_Purpose_Nm__c=prodExtAttrAct.Core_SW_Prod_Non_Commercial_Purpose_Nm__c;
                    extAttrToInsert.Core_SW_Prod_Expiration_Duration_Nbr__c=prodExtAttrAct.Core_SW_Prod_Expiration_Duration_Nbr__c;
                    extAttrToInsert.Core_SW_Lic_Rehostable_Ind__c=prodExtAttrAct.Core_SW_Lic_Rehostable_Ind__c;
                    extAttrToInsert.Core_SW_Lic_Renewal_Period_Nbr__c=prodExtAttrAct.Core_SW_Lic_Renewal_Period_Nbr__c;
                    extAttrToInsert.Core_Prod_QTE_Slow_Moving_Inventory_Ind__c=prodExtAttrAct.Core_Prod_QTE_Slow_Moving_Inventory_Ind__c;
                    extAttrToInsert.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c=prodExtAttrAct.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c;
                    extAttrToInsert.Core_SW_Lic_Type_Nm__c=prodExtAttrAct.Core_SW_Lic_Type_Nm__c;
                    extAttrToInsert.Core_Prod_Tool_Type_Nm__c=prodExtAttrAct.Core_Prod_Tool_Type_Nm__c;
                    extAttrToInsert.Core_Foundation_Product_Id__c=prodExtAttrAct.Core_Foundation_Product_Id__c;
                    extAttrToInsert.Core_SW_Prod_Web_Dsc__c=prodExtAttrAct.Core_SW_Prod_Web_Dsc__c;
                    extAttrToInsert.Core_SW_Lic_Web_Displayable_Ind__c=prodExtAttrAct.Core_SW_Lic_Web_Displayable_Ind__c;
                    extAttrToInsert.Core_SW_Lic_Windows_Download_URL_Txt__c=prodExtAttrAct.Core_SW_Lic_Windows_Download_URL_Txt__c;
                    extAttrListToInsert.add(extAttrToInsert);
                }     
            }
        }
        
        if(!extAttrListToInsert.isEmpty()){
            List<Core_Product_Ext_Attribute__c> failedRec=new List<Core_Product_Ext_Attribute__c>();
            Database.SaveResult[] result=Database.insert(extAttrListToInsert,false);
            for(Integer i=0;i<result.size();i++){
                if (!result[i].isSuccess()) {
                    failedRec.add(extAttrListToInsert[i]);
                }
            }
            if(failedRec.size()>0){
                PSG_Utility.createCoreLogEntry('PSG_ActiveProductExtAttrHandler','updateExtAttributesOnActiveProduct','Error while Copying Extended Attribute records to Active Products.','Failed Records : \n '+failedRec+'\n\n Database SaveResult : '+result,'Product','Low','');
            }
        }
    }*/
}