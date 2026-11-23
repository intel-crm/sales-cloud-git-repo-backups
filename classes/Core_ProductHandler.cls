/******************************************************************************************************************************************
Class Name  : Core_ProductHandler
Version     : 1.0 
Created Date: 16 OCT 2015
Function    : Handles all trigger logic for the object Product2. This implements the new trigger framework agreed on in Q3 2015.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 10/16/2015              Original version
*****************************************************************************************************************************************/
public class Core_ProductHandler {
    
   
    // Static variables to prevent unwanted re-entry
    public static Boolean alreadyUpdatedOppProductField = false;
    
    // DML static variables to perform all DML in consolidated operations at the end
    public static Map<Id,sObject> objectsToInsert = new Map<Id,sObject>();
    public static Boolean objectsToInsertCounter = false;
    
    public static Map<Id,sObject> objectsToUpdate = new Map<Id,sObject>();
    public static Boolean objectsToUpdateCounter = false;
    
    public static Map<Id,sObject> objectsToDelete = new Map<Id,sObject>();
    public static Boolean objectsToDeleteCounter = false;
    
    // Map of our Trigger execution flags
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution;
    
    
    // Handle all "After" logic on Products
    public static void afterMethod(List<Product2> oldList, List<Product2> newList, Map<Id,Product2> oldMap, Map<Id,Product2> newMap)
    {        
        mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
        //if (Trigger.isInsert) {
        // Placeholder for future code
        //}
        /**Commented by Kavyashree HR(Infosys Team) as a part of US757567
if (Trigger.isUpdate) {
Core_ProductOpportunity.oppProductConcatenatedFieldUpdate(oldList, newList, oldMap, newMap);
}**/
        //if (Trigger.isDelete) {
        // Placeholder for future code
        //}
        
        // Perform any inserts, if we have anything to insert
        /*if (!objectsToInsertCounter) {
objectsToInsertCounter = true;

if (objectsToInsert.size() > 0) {
insert objectsToInsert.values();
objectsToInsert.clear();
}
}*/
        
        // Perform any updates, if we have anything to update
        if (!objectsToUpdateCounter) {
            objectsToUpdateCounter = true;
            
            if (objectsToUpdate.size() > 0) {
                update objectsToUpdate.values();
                objectsToUpdate.clear();
            }
        }
        
        // Perform any deletions, if we have anything to delete
        /*if (!objectsToDeleteCounter) {
objectsToDeleteCounter = true;

if (objectsToDelete.size() > 0) {
delete objectsToDelete.values();
objectsToDelete.clear();
}
}*/
    }
    
    public static void updateProductDensity(List<Product2> newProdList){
        try{
        //Map<String, Core_Product_Density_Rules__mdt> densityMapping = new Map<String, Core_Product_Density_Rules__mdt>();
        List<Core_Product_Density_Rule__c> densityMapList = new List<Core_Product_Density_Rule__c>();
        for(Core_Product_Density_Rule__c density : [Select Id, Core_Sequence_Number__c, Core_Code_Name__c, Core_OPN_Start_Char__c, Core_OPN_End_Char__c, Core_OPN_Char_Contain__c, 
                                                    Core_Density_Start_Char__c, Core_Density_End_Char__c, Core_Density_Output_Suffix__c,Core_IsActive__c 
                                                    from Core_Product_Density_Rule__c where Core_IsActive__c  = True Order by Core_Sequence_Number__c asc]){
                                                        //densityMapping.put(density.Code_Name__c, density);
                                                        densityMapList.add(density);
                                                    }
        //System.debug('***Density RULE LIST - '+densityMapList);
        for(Product2 prod : newProdList){ ///1st product compare 1st product's CodeName 
            if(densityMapList!=null && densityMapList.size()>0 && prod.IsActive && prod.Core_Hierarchy_ID__c == '59' && !String.isBlank(prod.Core_OPN__c)  && prod.Core_OPN__c!=null && !String.isBlank(prod.Core_Code_Name__c) && prod.Core_Code_Name__c!=null){ //prod.Core_Product_Org__c == 'Sales' &&
                for(Core_Product_Density_Rule__c rule : densityMapList){
                    //if(!String.isBlank(rule.Core_Density_Start_Char__c) && !String.isBlank(rule.Core_Density_End_Char__c)){
                    List<String> startStrList = rule.Core_Density_Start_Char__c.split(','); //1,4
                    List<String> endStrList = rule.Core_Density_End_Char__c.split(',');  //6,7
                    Set<String> codeNameSet = new Set<String>();
                        if(!String.isBlank(rule.Core_Code_Name__c)){
                            List<String> codeNameSetTemp = rule.Core_Code_Name__c.split(',');
                            for(String codeNameToUpper: codeNameSetTemp){
                                codeNameSet.add(codeNameToUpper.toUpperCase());
                            }
                        }
                    
                    //codeNameSet.addAll(rule.Core_Code_Name__c.split(',')); //{'ARRIA 10 GX','ARRIA 10 SX','Intel® Arria® 10 GX','Intel® Arria® 10 SX'} contains1st product compare 1st product's CodeName 
                    //System.debug('****CODE NAME - '+codeNameSet);
                    //System.debug('****CODENAMEContains Line:103 - '+prod.Core_Code_Name__c);
                    if(!String.isBlank(prod.Core_Code_Name__c) && prod.Core_Code_Name__c!=null && prod.Core_Code_Name__c.length()>0 && codeNameSet!=null && codeNameSet.contains(prod.Core_Code_Name__c.toUpperCase())){
                        //System.debug('****CODENAMEContains Line:103 Enter IF Condition - '+prod.Core_Code_Name__c);
                        //System.debug('#G:Core_OPN_Char_Contain__c'+rule.Core_OPN_Char_Contain__c);
                        if(rule.Core_OPN_Char_Contain__c == 'NA'){
                            //System.debug('****OPNContains Line:104 - '+rule.Core_OPN_Char_Contain__c);
                            //System.debug('****DensityStrList Size - '+startStrList.size());
                            if(startStrList != null && startStrList.size() > 1){
                                
                                string conCatString = concatenateString(startStrList[0], startStrList[1], endStrList[0],endStrList[1], prod.Core_OPN__c );
                                String density = '';
                                if(/*!String.isBlank(rule.Core_Density_Output_Suffix__c)  &&*/ rule.Core_Density_Output_Suffix__c != null) {density = rule.Core_Density_Output_Suffix__c;}
                                prod.Core_Product_Density_Value__c =  conCatString+density;
                                system.debug('#G:executed:1:');
                                break;
                            }else{
                                
                                String density = '';
                                if(!rule.Core_Density_End_Char__c.isNumeric()){
                                    rule.Core_Density_End_Char__c = String.valueOf(prod.Core_OPN__c.indexOf(rule.Core_Density_End_Char__c));
                                }
                                if(/*!String.isBlank(rule.Core_Density_Output_Suffix__c)  &&*/  rule.Core_Density_Output_Suffix__c != null) {density = rule.Core_Density_Output_Suffix__c;}
                                
                                if(!String.isBlank(prod.Core_OPN__c) && !String.isBlank(rule.Core_Density_End_Char__c) && !String.isBlank(rule.Core_Density_Start_Char__c) && prod.Core_OPN__c.length()>=Integer.valueOf(rule.Core_Density_End_Char__c) - Integer.valueOf(rule.Core_Density_Start_Char__c)){
                                    prod.Core_Product_Density_Value__c =  prod.Core_OPN__c.substring(Integer.valueOf(rule.Core_Density_Start_Char__c), Integer.valueOf(rule.Core_Density_End_Char__c))+density;
                                }
                                system.debug('#G:executed:2:');
                                break;
                            }
                        }else{
                            List<String> startOPNStrList = String.valueOf(rule.Core_OPN_Start_Char__c).split(','); //1,4
                            List<String> endOPNStrList = String.valueOf(rule.Core_OPN_End_Char__c).split(',');  //6,7
                            
                            //System.debug('#****START & END OPN LIST - '+startOPNStrList+' --- '+endOPNStrList);
                            //System.debug('#G:startOPNStrList:'+startOPNStrList.size());
                            //System.debug('#G:prod.Core_OPN__c:'+prod.Core_OPN__c);
                            if(startOPNStrList != null && startOPNStrList.size() > 1){
                               string conCatString = concatenateString(startOPNStrList[0],startOPNStrList[1],endOPNStrList[0], endOPNStrList[1], prod.Core_OPN__c );
                                Set<String> opnContainsSet = new Set<String>();
                                    for(String opn : rule.Core_OPN_Char_Contain__c.split(',') ){
                                        opnContainsSet.add(opn.trim());
                                    }
                                //System.debug('#G:OPN:opnConcat:'+conCatString);
                                //System.debug('#G:OPN:opnContainsSet:'+opnContainsSet);
                                if(opnContainsSet.contains(conCatString)){
                                    List<String> startStrList2 = rule.Core_Density_Start_Char__c.split(','); //1,4
                                    List<String> endStrList2 = rule.Core_Density_End_Char__c.split(',');  //6,7
                                    
                                    //System.debug('#G:OPN:startStrList2:'+startStrList2);
                                    //System.debug('#G:OPN:endStrList2:'+endStrList2);
                                    if(startStrList2 != null && startStrList2.size() > 1){	
                                        
										string conCatStringSecond = concatenateString(startStrList2[0],startStrList2[1], endStrList2[0], endStrList2[1], prod.Core_OPN__c );                                        
                                        String density = '';
                                        if(/*!String.isBlank(rule.Core_Density_Output_Suffix__c) &&*/ rule.Core_Density_Output_Suffix__c != null) {density = rule.Core_Density_Output_Suffix__c;}
                                        prod.Core_Product_Density_Value__c =  conCatStringSecond+density;
                                        //system.debug('#G:executed:3:');
                                        break;
                                    }else{
                                        
                                        //system.debug('#G:end:0:'+rule.Core_Density_End_Char__c);
                                        //system.debug('#G:end:1:'+prod.Core_OPN__c);
                                        String density = '';
                                        if(!rule.Core_Density_End_Char__c.isNumeric()){
                                            rule.Core_Density_End_Char__c = String.valueOf(prod.Core_OPN__c.indexOf(rule.Core_Density_End_Char__c));
                                        }
                                        
                                        //system.debug('#G:end:3:'+rule.Core_Density_Output_Suffix__c);
                                        //system.debug('#G:end:4:'+rule.Core_Density_Start_Char__c);
                                        //system.debug('#G:end:4:'+rule.Core_Density_End_Char__c);
                                        
                                        if(/*!String.isBlank(rule.Core_Density_Output_Suffix__c) &&*/ rule.Core_Density_Output_Suffix__c != null) {density = rule.Core_Density_Output_Suffix__c;
                                                                                        //system.debug('#G:end:2:'+density);
                                                                                       }
                                        if(!String.isBlank(prod.Core_OPN__c) && !String.isBlank(rule.Core_Density_End_Char__c) && !String.isBlank(rule.Core_Density_Start_Char__c) && prod.Core_OPN__c.length()>=Integer.valueOf(rule.Core_Density_End_Char__c) - Integer.valueOf(rule.Core_Density_Start_Char__c)){
                                            prod.Core_Product_Density_Value__c =  prod.Core_OPN__c.substring(Integer.valueOf(rule.Core_Density_Start_Char__c), Integer.valueOf(rule.Core_Density_End_Char__c))+density;
                                        }
                                        system.debug('#G:executed:4:');
                                        break;
                                    }
                                }
                                
                            }else{   
                                String opnCheck;
                                if(!string.isEmpty(rule.Core_OPN_Start_Char__c) && !string.isEmpty(rule.Core_OPN_End_Char__c) && prod.Core_OPN__c.length()>= Integer.valueOf(rule.Core_OPN_End_Char__c) - Integer.valueOf(rule.Core_OPN_Start_Char__c)){
                                    //system.debug('#G:opnCheck:'+rule.Core_OPN_Start_Char__c+','+rule.Core_OPN_End_Char__c);
                                    opnCheck = prod.Core_OPN__c.substring(Integer.valueOf(rule.Core_OPN_Start_Char__c), Integer.valueOf(rule.Core_OPN_End_Char__c));    
                                }
                                
                                Set<String> opnContainsSet = new Set<String>();
                                //Gireesh:Start
                                for(String opn : rule.Core_OPN_Char_Contain__c.split(',') ){
                                    opnContainsSet.add(opn.trim());
                                }
                                //Gireesh:End                                
                                //System.debug('****OPN opnCheck - '+opnCheck);
                                //System.debug('****OPN opnContainsSet - '+opnContainsSet);
                                if(opnContainsSet.contains(opnCheck)){
                                    System.debug('***INSIDE OPN CONTAINS****');
                                    List<String> startStrList1 = rule.Core_Density_Start_Char__c.split(','); //1,4
                                    List<String> endStrList1 = rule.Core_Density_End_Char__c.split(',');  //6,7
                                    //System.debug('****START & END DENSITY STRING - '+startStrList1+' --- '+endStrList1);
                                    //System.debug('#G:Density:0:'+opnCheck+'--'+opnContainsSet);
                                    //System.debug('#G:Density:1:'+startStrList1+'--'+endStrList1);
                                    if(startStrList1 != null && startStrList1.size() > 1){		
                                        string conCatString = concatenateString(startStrList1[0],startStrList1[1], endStrList1[0], endStrList1[1], prod.Core_OPN__c);
                                        String density = '';
                                        if(rule.Core_Density_Output_Suffix__c != null) {
                                            density = rule.Core_Density_Output_Suffix__c;
                                        }
                                        //system.debug('#G:densityAdd:'+rule.Core_Density_Output_Suffix__c);
                                        prod.Core_Product_Density_Value__c = conCatString+density;
                                        //System.debug('#G:ProductCode:'+prod.Core_Product_Density_Value__c);
                                        system.debug('#G:executed:5:');
                                        break;
                                    }else{
                                        String density = '';
                                        if(!rule.Core_Density_End_Char__c.isNumeric()){
                                            system.debug('#G:NA');
                                            rule.Core_Density_End_Char__c = String.valueOf(prod.Core_OPN__c.indexOf(rule.Core_Density_End_Char__c));
                                        }
                                        if(/*!String.isBlank(rule.Core_Density_Output_Suffix__c) &&*/ rule.Core_Density_Output_Suffix__c != null) {density = rule.Core_Density_Output_Suffix__c;}
                                        
                                        //Gireesh:Start
                                        integer densityStartChar;
                                        integer densityEndChar ;
                                        string densityConcat;
                                        if(/*!String.isBlank(rule.Core_Density_Output_Suffix__c) &&*/ rule.Core_Density_Start_Char__c!='NA' && rule.Core_Density_End_Char__c!='NA'){
                                            //system.debug('#G:executed:6:check:'+rule.Core_Density_Start_Char__c+','+rule.Core_Density_End_Char__c);
                                            densityStartChar = Integer.valueOf(rule.Core_Density_Start_Char__c);
                                            densityEndChar = Integer.valueOf(rule.Core_Density_End_Char__c);
                                            if(prod.Core_OPN__c.length()>=densityEndChar - densityStartChar){
                                            densityConcat = prod.Core_OPN__c.substring(densityStartChar, densityEndChar);
                                            }
                                            //system.debug('#G:executed:6:check1:'+densityConcat);
                                        }
                                        prod.Core_Product_Density_Value__c = !String.isEmpty(densityConcat)?densityConcat+density : density;
										//Gireesh:End
                                        
                                        //System.debug('***ProductCode - '+prod.Core_Product_Density_Value__c);
                                        system.debug('#G:executed:6:');
                                        break;
                                    }
                                }
                            }
                        }                        
                    }
                //}
                }
            }
        }
    }
        catch(Exception ex){
            system.debug('#ex:'+ex.getLineNumber());
            system.debug('#ex:'+ex.getMessage());
            system.debug('#ex:'+ex.getCause());
            system.debug('#ex:'+ex.getTypeName());
        }
    }
    
    private static string  concatenateString(string firststartChar, string firstendChar, string secondstartChar, string secondendChar, string getSubsString){
        
        Integer firststartCharParsed;
        Integer firstendCharParsed;
        Integer secondstartCharParsed;
        Integer secondendCharParsed;
        String firstSubStringExtract=null;
        String secondSubStringExtract=null;
        
        if(firststartChar!='NA' && !String.isBlank(firststartChar)){
            firststartCharParsed = Integer.valueOf(firststartChar);    
        }
        
        if(firstendChar!='NA' && !String.isBlank(firstendChar)){
            firstendCharParsed = Integer.valueOf(firstendChar);
        }
        if(secondstartChar!='NA' && !String.isBlank(secondstartChar)){
            secondstartCharParsed = Integer.valueOf(secondstartChar);
        }
        
        if(secondendChar!='NA' && !String.isBlank(secondendChar)){
            secondendCharParsed = Integer.valueOf(secondendChar);
        }
        
        if( !String.isBlank(getSubsString) & firststartCharParsed>=0 && firstendCharParsed>=0  && getSubsString.length()>=firstendCharParsed - firststartCharParsed){
            firstSubStringExtract = getSubsString.substring(firststartCharParsed, firstendCharParsed);
        }
        
        if(!String.isBlank(getSubsString) && secondstartCharParsed>=0 && secondendCharParsed>=0 && getSubsString.length()>=secondendCharParsed - secondstartCharParsed){
            secondSubStringExtract = getSubsString.substring(secondstartCharParsed, secondendCharParsed);  
        }
        
        if(firstSubStringExtract!=null || secondSubStringExtract!=null){
            return firstSubStringExtract + secondSubStringExtract;    
        }
        else{
            return '';
        }
        
        
    }
   
    //Sandhya : US1014012 - To restrict Integration from editting Sales Visible flag after User edit
   public static void updateSalesVisibleFlagForPSG(List<Product2> newProdList,Map<Id,Product2> oldProdMap){
        System.debug('Inside updateFlag');
        List<Product2> prodUpdateList = new List<Product2>();
       //Get the Integration Profile Name
        Id profileId= userinfo.getProfileId();
		String loggedInProfileName=[Select Id,Name from Profile where Id=:profileId].Name;
		//Get the Profile name from Label     
        String integrationProfile = Label.PSG_Integration_Profile;
       
        //Check if the User has editted field, DO not change it via Integration
        for(Product2 psgProdRecord : newProdList){
           If (loggedInProfileName.equals(integrationProfile) && psgProdRecord.Core_Sales_Visible_Flag_User_Edit__c==true 
                && oldProdMap.get(psgProdRecord.Id).Core_Sales_Visible_Flag__c !=psgProdRecord.Core_Sales_Visible_Flag__c )
           {
                //if there is user edit change, then retain the older value without overriding the value through Integration.
                psgProdRecord.Core_Sales_Visible_Flag__c = oldProdMap.get(psgProdRecord.Id).Core_Sales_Visible_Flag__c;
                               
            }
        }
       
	}
    
	//Gireesh:Update SalesVisibleFlag and DesignRegistrationEligibleFlags as false when Status = OB for an active PSG product
    public static void updateSalesVisibleDesignRegistrationFlags(List<Product2> newProdList){
        for(Product2 newProduct: newProdList){
            if(newProduct.Core_Product_Status__c!=null && newProduct.Core_Product_Status__c=='OB' && newProduct.IsActive && newProduct.Core_Product_Type_Nm__c!=Null 
               && (newProduct.Core_Product_Type_Nm__c=='Tool' || newProduct.Core_Product_Type_Nm__c=='Component')){
                newProduct.Core_Sales_Visible_Flag__c = False;
                newProduct.Core_Design_Registration_Eligible_Ind__c = False;                
            }
        }
    }
    
    //Sandhya : Restrict isActive flag to true when Product Status = RT,NO,NT
    public static void checkProductStatus(List<Product2> newProdList){
        Set<String> prodOPNActiveSet=new Set<String>();
        String statusValues = Label.PSG_ProductStatus;
        List<String> statusList = statusValues.split(',');
        for(Product2 prod : newProdList){
            if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.isActive == true && prod.Core_Product_Org__c=='Sales' && statusList.contains(prod.Core_Product_Status__c)){
                system.debug('prod==='+prod.isActive+' '+prod.Core_Product_Status__c);
                prod.isActive = false;
            }            
        }
      
    }
   

}