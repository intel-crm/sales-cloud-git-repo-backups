/****************************************************************************************************
Apex Class Name : PSG_ActiveProduct3ExtAttrHandler
Version         : 1.0 
Created Date    : 08/30/2021
Function        : This class is used used as part of Product trigger for all the PSG functionalities
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya D                    08/30/2021               Created
*****************************************************************************************************/
public class Core_PSG_ActiveProduct3ExtAttrHandler {   
    
    /************************************************************************************************************
	*Method Name : updateExtAttributesOnActiveProduct
	*Created Date: 08/30/2021
	*Author: Sandhya D 
	*Description : Updates Core_Product_Ext_Attribute__c records..
	************************************************************************************************************/
    public static void updateExtAttributesOnActiveProduct(List<Product3__c> newList,Map<Id,Product3__c> oldMap,Boolean IsInsert){
      
        List<Product3__c> releaseProdList=new List<Product3__c>();
        Map<String,String> recentActiveProdMap =new Map<String,String>();
        Set<String> opnSet=new Set<String>();
        Map<String,Product3__c> opnProdMap=new Map<String,Product3__c>();
        Map<String,List<Core_Product_Ext_Attribute__c>> existingPreReleaseExtAttrMap=new Map<String,List<Core_Product_Ext_Attribute__c>>();
        List<Core_Product_Ext_Attribute__c> extAttrListToInsert=new List<Core_Product_Ext_Attribute__c>();
        //Map<String,String> prodHierarchyMDMap = new Map<String,String>();
        List<Product3__c> preReleaseProdList=new List<Product3__c>();
       List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        if(newList != null ){
            for(Product3__c prod : newList){ 
                if(IsInsert){
                    if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.IsActive__c && prod.Core_Product_Org__c=='Sales' ){
                        releaseProdList.add(prod);
                    	opnSet.add(prod.core_OPN__c);
                    }
                }else{
                    if((prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.Core_Product_Org__c=='Sales') && ((oldMap.get(prod.Id).IsActive__c != prod.IsActive__c && prod.IsActive__c) || (oldMap.get(prod.Id).core_OPN__c != prod.Core_OPN__c && oldMap.get(prod.Id).core_OPN__c == null && prod.Core_OPN__c!=null)) ){
                     //if((prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.Core_Product_Org__c=='Sales') && ((oldMap.get(prod.Id).IsActive__c != prod.IsActive__c && prod.IsActive__c) || (oldMap.get(prod.Id).core_OPN__c != prod.Core_OPN__c )) ){
               			releaseProdList.add(prod);
                    	opnSet.add(prod.core_OPN__c);
                    }
                }
            }
            }               
        
        if(!opnSet.isEmpty() || opnSet!=null){
            //take the Active latest pre release product based on Createddate. There could be multiple inactive, hence added Order By createdDate
          // Map<String,String>
           recentActiveProdMap = PSG_Product3BusinessLogic.getRecentActivatedProduct(opnSet,releaseProdList);
            for(Product3__c prodRec: [SELECT Id,core_OPN__c from Product3__c WHERE Id in :recentActiveProdMap.values()]){  	
            preReleaseProdList.add(prodRec);
                if(!opnProdMap.containsKey(prodRec.Core_OPN__c)){
                    opnProdMap.put(prodRec.core_OPN__c,prodRec);
                }
            }
        }
        //Commented By Abhigna
       /* if(!opnProdMap.isEmpty()){ 
            List<Product3__c> extendedAttributeList = opnProdMap.values();
            for(Core_Product_Ext_Attribute__c preReleaseExtAttr: [select Id,Core_Product_Id__c,Core_SW_Prod_Additional_Dsc__c,Core_Prod_QTE_Alt_LGSTS_NW_Enabled_Ind__c,Core_SW_Lic_Authorization_Cd__c,Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c,Core_SW_Lic_Companion_Ind__c,
                                                                  Core_SW_Lic_File_Data_Encryption_Std_Cd__c,Core_SW_Lic_Enforcement_Method_Nm__c,Core_Foundation_Product_Id__c,Core_SW_Lic_Comment_Txt__c,Core_SW_Lic_Group_Id__c,Core_SW_Lic_Generator_Parameter_Txt__c,
                                                                  Core_SW_Lic_Linux_Download_URL_Txt__c,Core_SW_Prod_Max_Rehost_Cnt__c,Core_SW_Prod_Non_Commercial_Purpose_Nm__c,Core_SW_Prod_Expiration_Duration_Nbr__c,
                                                                  Core_SW_Lic_Rehostable_Ind__c,Core_SW_Lic_Renewal_Period_Nbr__c,Core_Prod_QTE_Slow_Moving_Inventory_Ind__c,Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Core_SW_Lic_Type_Nm__c,Core_Prod_Tool_Type_Nm__c,
                                                                  Core_SW_Prod_Web_Dsc__c,Core_SW_Lic_Web_Displayable_Ind__c,Core_SW_Lic_Windows_Download_URL_Txt__c 
                                                                  from Core_Product_Ext_Attribute__c where Core_Product_Id__c in:extendedAttributeList]){
            List<Core_Product_Ext_Attribute__c> preReleaseExtAttrList=existingPreReleaseExtAttrMap.containsKey(preReleaseExtAttr.Core_Product_Id__c)?existingPreReleaseExtAttrMap.get(preReleaseExtAttr.Core_Product_Id__c):new List<Core_Product_Ext_Attribute__c>();
            preReleaseExtAttrList.add(preReleaseExtAttr);
            existingPreReleaseExtAttrMap.put(preReleaseExtAttr.Core_Product_Id__c,preReleaseExtAttrList); 
            }
        } */
        for(Product3__c prod:releaseProdList){ 
            if(opnProdMap.containsKey(prod.Core_OPN__c) && existingPreReleaseExtAttrMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){                               
                //Clone the extended Attributes from Pre release to release products
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
                captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Error while Copying Signal Code and Product Class records to Active Products:'+failedRec, Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSG_ActiveProduct3ExtAttrHandler', Core_When__c = System.now())); 
            }
        }
        updateSignalCodeOnAllProducts( newList,oldMap,  recentActiveProdMap);
             
    } 
    
	/************************************************************************************************************
	*Method Name : updateSignalCodeOnActiveProduct
	*Created Date: 09/16/2021
	*Author: Sandhya D 
	*Description : Updates Signal Code and Product Class from Pre release to Release products records.
	************************************************************************************************************/    
    public static void updateSignalCodeOnActiveProduct(List<Product3__c> newList){
      
        Map<String,Product3__c> opnSignalCodeMap=new Map<String,Product3__c>();
        List<Product3__c> releaseProdList=new List<Product3__c>();
        List<Product3__c> preReleaseProdList=new List<Product3__c>();
        Map<String,Product3__c> opnProdMap=new Map<String,Product3__c>();
        Set<String> opnSet=new Set<String>();
        List<Product3__c> preReleaseSignalCodeList=new List<Product3__c>();
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        if(newList != null){
            for(Product3__c prod : newList){               
            	//if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.core_OPN__c!=null && prod.IsActive__c && prod.Core_Hierarchy_ID__c =='43' && prod.Core_Product_Org__c=='Sales' ){
                if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.core_OPN__c!=null && prod.IsActive__c &&  prod.Core_Product_Org__c=='Sales' ){
                    releaseProdList.add(prod);
                    opnSet.add(prod.core_OPN__c);
                }
            }               
        }
     
        if(!opnSet.isEmpty() || opnSet!=null){
            //take the Active latest pre release product based on Createddate. There could be multiple inactive, hence added Order By createdDate
           Map<String,String> recentActiveProdMap = PSG_Product3BusinessLogic.getRecentActivatedProduct(opnSet,releaseProdList);
            for(Product3__c prodRec: [SELECT Id,core_OPN__c , Core_Item_Class_Nm__c, Core_Item_Signal_Cd__c,  Core_Sales_Visible_Flag__c, Core_Sales_Visible_Flag_User_Edit__c from Product3__c WHERE Id in :recentActiveProdMap.values()]){  	
            preReleaseProdList.add(prodRec);
                if(!opnProdMap.containsKey(prodRec.Core_OPN__c)){
                    opnProdMap.put(prodRec.core_OPN__c,prodRec);
                     system.debug('-----'+ prodRec);
                }
            }
        }
        
        try{
              for(Product3__c prod:releaseProdList){
          if(opnProdMap.containsKey(prod.Core_OPN__c)){  
           //if(opnSignalCodeMap.get(prod.Core_OPN__c).Core_Item_Class_Nm__c !=null && opnSignalCodeMap.get(prod.Core_OPN__c).Core_Item_Signal_Cd__c != null ){
             // system.debug('--prod---'+ prod); 	
               // prod.Core_Item_Class_Nm__c = opnProdMap.get(prod.Core_OPN__c).Core_Item_Class_Nm__c;
                prod.Core_Item_Signal_Cd__c = opnProdMap.get(prod.Core_OPN__c).Core_Item_Signal_Cd__c;
           } 
             } 
        }catch(Exception e){
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Error while Copying Signal Code and Product Class records to Active Products', Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSG_ActiveProduct3ExtAttrHandler', Core_When__c = System.now())); 
        }
          system.debug('Before Update called -- updateSignalCodeOnActiveProduct end');
        }
    
    
    /************************************************************************************************************
	*Method Name : updateSignalCodeOnAllProducts
	*Created Date: 09/16/2021
	*Author: Sandhya D 
	*Description : Updates Signal Code and Product Class from Pre release to Release products records.
	************************************************************************************************************/    
    private static void updateSignalCodeOnAllProducts(List<Product3__c> newList,Map<Id,Product3__c> oldMap, Map<String,String> recentActiveProdMap){
          system.debug('Before Update called -- updateSignalCodeOnAllProducts start');
        Map<String,List<Product3__c>> opnSignalCodeMap=new Map<String,List<Product3__c>>();
        Set<String> opnSet=new Set<String>();
        List<Product3__c> preReleaseSignalCodeList=new List<Product3__c>();
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        Map<String,String> releasedProdSignalCode=new Map<String,String>();
        List<Product3__c> prodListToUpdate = new List<Product3__c>();
        List<Product3__c> releaseProdList=new List<Product3__c>();
        List<Product3__c> preReleaseProdList=new List<Product3__c>();
        Map<String,Product3__c> opnProdMap=new Map<String,Product3__c>();       
        
        if(newList != null && oldMap!= null){
            for(Product3__c prod : newList){   
                
            	//if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.core_OPN__c!=null && prod.IsActive__c && oldMap.get(prod.Id).Core_Item_Signal_Cd__c != prod.Core_Item_Signal_Cd__c && (prod.Core_Hierarchy_ID__c =='43'|| prod.Core_Hierarchy_ID__c =='59') && prod.Core_Product_Org__c=='Sales' ){
                if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.core_OPN__c!=null && prod.IsActive__c &&  prod.Core_Product_Org__c=='Sales' ){
                    opnSet.add(prod.core_OPN__c);
                    releaseProdList.add(prod);
                    releasedProdSignalCode.put(prod.core_OPN__c,prod.Core_Item_Signal_Cd__c);
                }
            } 
        }
      
         if(!opnSet.isEmpty() || opnSet!=null){
            //take the Active latest pre release product based on Createddate. There could be multiple inactive, hence added Order By createdDate
           //Map<String,String> 
              // recentActiveProdMap = PSG_ProductBusinessLogic.getRecentActivatedProduct(opnSet,releaseProdList);
            for(Product3__c prodRec: [SELECT Id,core_OPN__c, Core_Item_Class_Nm__c,Core_Item_Signal_Cd__c, Core_Sales_Visible_Flag__c, Core_Sales_Visible_Flag_User_Edit__c  from Product3__c WHERE Id in :recentActiveProdMap.values()]){  	
            preReleaseProdList.add(prodRec);
                if(!opnProdMap.containsKey(prodRec.Core_OPN__c)){
                    opnProdMap.put(prodRec.core_OPN__c,prodRec);
                }
            }
        }

    
          for(Product3__c prod:releaseProdList){ 
          if(opnProdMap.containsKey(prod.Core_OPN__c)){ 
             
               Product3__c prodNew = new Product3__c();
               prodNew.Id = prod.Id;
               //prodNew.Core_Item_Class_Nm__c = opnProdMap.get(prod.Core_OPN__c).Core_Item_Class_Nm__c;
               prodNew.Core_Item_Signal_Cd__c = opnProdMap.get(prod.Core_OPN__c).Core_Item_Signal_Cd__c; 
                 system.debug('--prod---'+ prod); 
                system.debug('--opnProdMap.get(prod.Core_OPN__c).Core_Item_Signal_Cd__c---'+ opnProdMap.get(prod.Core_OPN__c).Core_Item_Signal_Cd__c); 
           	    //Shijas : Sales visible flag update - TWC3123-1712
               prodNew.Core_Sales_Visible_Flag__c = opnProdMap.get(prod.Core_OPN__c).Core_Sales_Visible_Flag__c;
               prodNew.Core_Sales_Visible_Flag_User_Edit__c = opnProdMap.get(prod.Core_OPN__c).Core_Sales_Visible_Flag_User_Edit__c;              
               prodListToUpdate.add(prodNew); 
            }
        }

        try{
        update prodListToUpdate;
        }catch(Exception e){
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Error while Copying Signal Code and Product Class records to All Products' + e.getStackTraceString() + e.getMessage(), Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSG_ActiveProduct3ExtAttrHandler', Core_When__c = System.now())); 
        }
        finally
        {
       // insert captureQueryErr;
        }
        
    } 
    //Sandhya
    public static void removeSignalCodeUpdatedProducts(List<Product3__c> newProductList, Map<Id,Product3__c> oldProductMap){
	
        List<Product3__c> signalCodeUnchangedProdList = new List<Product3__c>();
        for (Product3__c prod : newProductList){
            if(!(prod.Core_Item_Signal_Cd__c != oldProductMap.get(prod.Id).Core_Item_Signal_Cd__c)){
              
            signalCodeUnchangedProdList.add(prod);
            }
        }
        
        if(!signalCodeUnchangedProdList.isEmpty()){
        Core_PSG_ActiveProduct3ExtAttrHandler.updateSignalCodeOnActiveProduct(signalCodeUnchangedProdList); 
        }
       
	}
    
    
    public static void updateProductsWithoutSignalCode(List<Product3__c> newList,Map<Id,Product3__c> oldMap,Boolean IsInsert){
       
        Map<String,Product3__c> prodWithoutSignalCodeMap = new Map<String,Product3__c>();
        Map<String,Product3__c> existingProdWithSignalCodeMap = new Map<String,Product3__c>();
        List<Product3__c> prodWithoutSignalCodeMapUpdate = new List<Product3__c>();
    
        Boolean recursiveCheckSignalCode = true;
        if(recursiveCheckSignalCode){
        if(newList != null){
            for(Product3__c prodWithoutSignalCode : newList){
                if(IsInsert){
                if(String.isEmpty(prodWithoutSignalCode.Core_Item_Signal_Cd__c ) || prodWithoutSignalCode.Core_Item_Signal_Cd__c==null){
                    prodWithoutSignalCodeMap.put(prodWithoutSignalCode.Core_OPN__c,prodWithoutSignalCode);
                 
                }
                }else{
                    if((String.isEmpty(prodWithoutSignalCode.Core_Item_Signal_Cd__c ) || prodWithoutSignalCode.Core_Item_Signal_Cd__c==null)&& oldMap.get(prodWithoutSignalCode.Id).Core_Item_Signal_Cd__c !=prodWithoutSignalCode.Core_Item_Signal_Cd__c ){
                    prodWithoutSignalCodeMap.put(prodWithoutSignalCode.Core_OPN__c,prodWithoutSignalCode);
                    }
                }
                
            }
        }
        for(Product3__c existingProdWithSignalCode : [select id,name,Core_Item_Quotable_Ind__c,Core_Item_Shippable_Ind__c,Core_Item_Orderable_Ind__c,Core_Item_Price_Authorization_Ind__c,Core_Item_Signal_Cd__c,Core_OPN__c,Core_Item_Class_Nm__c from Product3__c where Core_OPN__c IN :prodWithoutSignalCodeMap.keySet() and Core_Product_Type__c = :Label.PSG_Product_Type_Identifier and Core_Product_Org__c='Sales' and Core_Item_Signal_Cd__c!=null]){
            existingProdWithSignalCodeMap.put(existingProdWithSignalCode.Core_OPN__c,existingProdWithSignalCode);
           
            
        }
        
        for(Product3__c prodRecSignalCode : prodWithoutSignalCodeMap.values()){
            if(existingProdWithSignalCodeMap.containskey(prodRecSignalCode.Core_OPN__c)){
           
                //prodRecSignalCode.Core_Item_Class_Nm__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Class_Nm__c;
                prodRecSignalCode.Core_Item_Signal_Cd__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Signal_Cd__c;
                prodRecSignalCode.Core_Item_Quotable_Ind__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Quotable_Ind__c;
                prodRecSignalCode.Core_Item_Shippable_Ind__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Shippable_Ind__c;
                prodRecSignalCode.Core_Item_Orderable_Ind__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Orderable_Ind__c;
                prodRecSignalCode.Core_Item_Price_Authorization_Ind__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Price_Authorization_Ind__c;
              prodWithoutSignalCodeMapUpdate.add(prodRecSignalCode);
            }
        }
           // update prodWithoutSignalCodeMapUpdate;
     recursiveCheckSignalCode = false;   
    }
        
    }
   
}