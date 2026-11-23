public class Core_Product3Handler {
    
    
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
    public static void afterMethod(List<Product3__c> oldList, List<Product3__c> newList, Map<Id,Product3__c> oldMap, Map<Id,Product3__c> newMap)
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
    
    public static void updateProductDensity(List<Product3__c> newProdList){
        
        try{
            //Map<String, Core_Product_Density_Rules__mdt> densityMapping = new Map<String, Core_Product_Density_Rules__mdt>();
            List<Core_Product_Density_Rule__c> densityMapList = new List<Core_Product_Density_Rule__c>();
            
            densityMapList = [Select Id, Core_Sequence_Number__c, Core_Code_Name__c, Core_OPN_Start_Char__c, Core_OPN_End_Char__c, Core_OPN_Char_Contain__c, 
                              Core_Density_Start_Char__c, Core_Density_End_Char__c, Core_Density_Output_Suffix__c,Core_IsActive__c 
                              from Core_Product_Density_Rule__c where Core_IsActive__c  = True Order by Core_Sequence_Number__c asc];
            
            /*******  
            for(Core_Product_Density_Rule__c density : [Select Id, Core_Sequence_Number__c, Core_Code_Name__c, Core_OPN_Start_Char__c, Core_OPN_End_Char__c, Core_OPN_Char_Contain__c, 
            Core_Density_Start_Char__c, Core_Density_End_Char__c, Core_Density_Output_Suffix__c,Core_IsActive__c 
            from Core_Product_Density_Rule__c where Core_IsActive__c  = True Order by Core_Sequence_Number__c asc]){
            //densityMapping.put(density.Code_Name__c, density);
            densityMapList.add(density);
            }
            ******/
            //System.debug('***Density RULE LIST - '+densityMapList);
            for(Product3__c prod : newProdList){ ///1st product compare 1st product's CodeName 
                if(densityMapList!=null && densityMapList.size()>0 && prod.IsActive__c&& prod.Core_Hierarchy_ID__c == '59' && !String.isBlank(prod.Core_OPN__c)  && prod.Core_OPN__c!=null && !String.isBlank(prod.Core_Code_Name__c) && prod.Core_Code_Name__c!=null){ //prod.Core_Product_Org__c == 'Sales' &&
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
    public static void updateSalesVisibleFlagForPSG(List<Product3__c> newProdList,Map<Id,Product3__c> oldProdMap){
        System.debug('Inside updateFlag');
        System.debug('Inside updateSalesVisibleFlagForPSG start');
        List<Product3__c> prodUpdateList = new List<Product3__c>();
        //Get the Integration Profile Name
        Id profileId= userinfo.getProfileId();
        String loggedInProfileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //Get the Profile name from Label     
        String integrationProfile = Label.PSG_Integration_Profile;
        
        for(Product3__c psgProdRecord : newProdList){
            //Check if the User has editted field, DO not change it via Integration
            If (loggedInProfileName.equals(integrationProfile) && psgProdRecord.Core_Sales_Visible_Flag_User_Edit__c==true 
                && oldProdMap.get(psgProdRecord.Id).Core_Sales_Visible_Flag__c !=psgProdRecord.Core_Sales_Visible_Flag__c 
                && oldProdMap.get(psgProdRecord.Id).Core_OPN__c ==psgProdRecord.Core_OPN__c )
            {
                
                //if there is user edit change, then retain the older value without overriding the value through Integration.
                psgProdRecord.Core_Sales_Visible_Flag__c = oldProdMap.get(psgProdRecord.Id).Core_Sales_Visible_Flag__c;
                psgProdRecord.Core_Sales_Visible_Flag_User_Edit__c = oldProdMap.get(psgProdRecord.Id).Core_Sales_Visible_Flag_User_Edit__c;               
            }
            
        }
        
    }
    
    //Gireesh:Update SalesVisibleFlag and DesignRegistrationEligibleFlags as false when Status = OB for an active PSG product
    public static void updateSalesVisibleDesignRegistrationFlags(List<Product3__c> newProdList){
        for(Product3__c newProduct: newProdList){
            if(newProduct.Core_Product_Status__c!=null && newProduct.Core_Product_Status__c=='OB' && newProduct.IsActive__c&& newProduct.Core_Product_Type_Nm__c!=Null 
               && (newProduct.Core_Product_Type_Nm__c=='Tool' || newProduct.Core_Product_Type_Nm__c=='Component')){
                   newProduct.Core_Sales_Visible_Flag__c = False;
                   newProduct.Core_Design_Registration_Eligible_Ind__c = False;                
               }
        }
    }
    
    //Sandhya : Restrict IsActive__cflag to true when Product Status = RT,NO,NT
    public static void checkProductStatus(List<Product3__c> newProdList){
        Set<String> prodOPNActiveSet=new Set<String>();
        String statusValues = Label.PSG_ProductStatus;
        List<String> statusList = statusValues.split(',');
        for(Product3__c prod : newProdList){
            if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.IsActive__c== true && prod.Core_Product_Org__c=='Sales' && statusList.contains(prod.Core_Product_Status__c)){
                system.debug('prod==='+prod.IsActive__c+' '+prod.Core_Product_Status__c);
                prod.IsActive__c= false;
            }            
        }      
    }
    
    // added methods from different classes for testing purpose
    // added from Core_ProductOpportunity
    
    public static void isProductNameChanged(List<Product3__c> newProductList, Map<Id,Product3__c> oldProductMap){
        //Updates the check box Core_IsName_Changed__c if the Product name changes which will be picked up by the batch class
        for (Product3__c prod : newProductList){
            if(prod.Name != oldProductMap.get(prod.Id).Name){
                prod.Core_Is_Name_Changed_Chk__c = true;
                prod.Core_Old_Product_Name_Txt__c = oldProductMap.get(prod.Id).Name;
                prod.Core_ProductName_Changed_Time_Dte__c = System.NOW();
            }
        }     
    }
    
    // added from PSG_Product3BusinessLogic
    public static void changeProductOnRelatedObjects(List<Product3__c> newList,Map<Id,Product3__c> oldMap,Boolean IsInsert){
        List<Product3__c> prodList=new List<Product3__c>();
        Set<String> opnSet=new Set<String>();
        Map<String,Product3__c> opnProdMap=new Map<String,Product3__c>();
        Map<String,List<PricebookEntry>> prodToPBEMap=new Map<String,List<PricebookEntry>>();
        Map<String,List<price_forward_cost__c>> prodToPFCMap=new Map<String,List<price_forward_cost__c>>();
        Map<String,Set<String>> prodToExisPBMap=new Map<String,Set<String>>();
        Map<String,PricebookEntry> exisprodToPBEMap=new Map<String,PricebookEntry>();
        Map<String,List<core_cpq_list_price__c>> exisprodToLPMap=new  Map<String,List<core_cpq_list_price__c>>();
        List<price_forward_cost__c> pfcListToInsert=new List<price_forward_cost__c>();
        List<PricebookEntry> pbeListToUpdate=new List<PricebookEntry>();
        List<PricebookEntry> pbeListToInsert=new List<PricebookEntry>();
        List<PricebookEntry> spbeListToInsert=new List<PricebookEntry>();
        Map<String,List<price_msvp__c>> prodToMSVPMap=new Map<String,List<price_msvp__c>>();
        Map<String,List<String>> newProdToExisFCMap=new Map<String,List<String>>();
        Map<String,List<String>> newProdToExisMSVPMap=new Map<String,List<String>>();
        Map<String,List<String>> newProdToExisLPMap=new Map<String,List<String>>();
        List<price_msvp__c> msvpListToInsert=new List<price_msvp__c>();
        
        Set<String> inactiveOPNS=new Set<String>();
        if(newList != null){
            for(Product3__c prod : newList){
                if(IsInsert){
                    if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.IsActive__c && prod.Core_Product_org__c == 'Sales'){
                        prodList.add(prod);
                        opnSet.add(prod.core_OPN__c);
                    }
                }else{
                    if((prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier) && prod.Core_Product_org__c == 'Sales' && ((oldMap.get(prod.Id).IsActive__c != prod.IsActive__c && prod.IsActive__c) || (oldMap.get(prod.Id).core_OPN__c != prod.Core_OPN__c && oldMap.get(prod.Id).core_OPN__c == null && prod.Core_OPN__c!=null)) ){
                        prodList.add(prod);
                        opnSet.add(prod.core_OPN__c);
                    } 
                    
                    if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.Core_Product_org__c == 'Sales' && oldMap.get(prod.Id).IsActive__c != prod.IsActive__c && !prod.IsActive__c && prod.Core_OPN__c!=null){
                        
                        inactiveOPNS.add(prod.core_OPN__c);
                    } 
                    
                }
            }
        }
        
        
        
        if(!opnSet.isEmpty()){
            Map<String,String> opnToExisProdIdMap = getRecentActivatedProduct(opnSet,prodList);            
            for(Product3__c prd: [SELECT Id,core_OPN__c from Product3__c WHERE Id in :opnToExisProdIdMap.values()]){
                if(!opnProdMap.containsKey(prd.core_OPN__c)){
                    opnProdMap.put(prd.core_OPN__c,prd);
                }                
            }
        }
        if(!opnProdMap.isEmpty()){
            List<Product3__c> exisProdList=opnProdMap.values();
            for(PricebookEntry pbe:[Select Id,Product3__c,PriceBook2Id,PriceBook2.Name,UnitPrice from PricebookEntry where Product3__c in :exisProdList]){
                List<PriceBookEntry> pbeList=prodToPBEMap.containsKey(pbe.Product3__c)?prodToPBEMap.get(pbe.Product3__c):new List<PricebookEntry>();
                pbeList.add(pbe);
                prodToPBEMap.put(pbe.Product3__c,pbeList);
            }
            if(!prodList.isEmpty()){
                for(PricebookEntry pbe: [Select Id,Product3__c,PriceBook2Id,UseStandardPrice from PricebookEntry where Product3__c in : prodList]){
                    Set<String> priceBookIds=prodToExisPBMap.containsKey(pbe.Product3__c)?prodToExisPBMap.get(pbe.Product3__c):new Set<String>();
                    priceBookIds.add(pbe.PriceBook2Id);
                    prodToExisPBMap.put(pbe.Product3__c,priceBookIds);
                    exisprodToPBEMap.put(pbe.Product3__c+'_'+pbe.Pricebook2Id,pbe);            
                }
                
                /*Getting the existing FC records of newly modified products.
            for(price_forward_cost__c fc: [Select Id,core_cpq_unique_id__c,core_cpq_product_nm__c from price_forward_cost__c where core_cpq_product_nm__c in : prodList]){
            if(newProdToExisFCMap.containsKey(fc.core_cpq_product_nm__c)){
            newProdToExisFCMap.get(fc.core_cpq_product_nm__c).add(fc.core_cpq_unique_id__c);
            }else{
            newProdToExisFCMap.put(fc.core_cpq_product_nm__c,new List<String>{fc.core_cpq_unique_id__c});
            }  
            }*/
                            
                            //Getting the existing MSVP records of newly modified products.
                            //  Commented by Abhigna
                            /*for(price_msvp__c msvp: [Select Id,core_cpq_unique_id__c,core_cpq_product_nm__c from price_msvp__c where core_cpq_product_nm__c in : prodList]){
            if(newProdToExisMSVPMap.containsKey(msvp.core_cpq_product_nm__c)){
            newProdToExisMSVPMap.get(msvp.core_cpq_product_nm__c).add(msvp.core_cpq_unique_id__c);
            }else{
            newProdToExisMSVPMap.put(msvp.core_cpq_product_nm__c,new List<String>{msvp.core_cpq_unique_id__c});
            }  
            } */
                            
                            //Getting the existing LP records of newly modified products.
                            //Commented By Abhigna
                            /*for(core_cpq_list_price__c lp: [Select Id,core_cpq_unique_id__c,core_cpq_product_name__c from core_cpq_list_price__c where core_cpq_product_name__c in : prodList]){
            if(newProdToExisLPMap.containsKey(lp.core_cpq_product_name__c)){
            newProdToExisLPMap.get(lp.core_cpq_product_name__c).add(lp.core_cpq_unique_id__c);
            }else{
            newProdToExisLPMap.put(lp.core_cpq_product_name__c,new List<String>{lp.core_cpq_unique_id__c});
            }  
            } */
                        }
                        /*String fcQuery='Select '+Label.PSG_ForwardCostFieldsToCopy+' from price_forward_cost__c where core_cpq_product_nm__c in :exisProdList';
            for(price_forward_cost__c pfc:(List<price_forward_cost__c>)Database.query(fcQuery)){
            List<price_forward_cost__c> pfcList=prodToPFCMap.containsKey(pfc.core_cpq_product_nm__c)?prodToPFCMap.get(pfc.core_cpq_product_nm__c):new List<price_forward_cost__c>();
            pfcList.add(pfc);
            prodToPFCMap.put(pfc.core_cpq_product_nm__c,pfcList);
            }*/
            String msvpQuery='Select '+Label.PSG_MSVPFieldsToCopy+' from price_msvp__c where core_cpq_product_nm__c in :exisProdList and (core_cpq_IsActive__c__c = true or core_cpq_effective_date_dt__c >= TODAY)';
            for(price_msvp__c msvp:(List<price_msvp__c>)Database.query(msvpQuery)){
                List<price_msvp__c> msvpList=prodToMSVPMap.containsKey(msvp.core_cpq_product_nm__c)?prodToMSVPMap.get(msvp.core_cpq_product_nm__c):new List<price_msvp__c>();
                msvpList.add(msvp);
                prodToMSVPMap.put(msvp.core_cpq_product_nm__c,msvpList);
            }
            
            String listPriceQuery='Select Id,core_cpq_product_name__c,Pricebookentry__c,core_cpq_Price_Book__c,core_cpq_lowerbound_qty__c,core_cpq_upperbound_qty__c,core_cpq_minimum_order_qty__c,core_cpq_multiple_order_quantity__c,core_cpq_list_price_amt__c  from core_cpq_list_price__c where core_cpq_product_name__c in :exisProdList';
            for(core_cpq_list_price__c lp:(List<core_cpq_list_price__c>)Database.query(listPriceQuery)){
                List<core_cpq_list_price__c> lpList=exisprodToLPMap.containsKey(''+lp.core_cpq_product_name__c+lp.core_cpq_Price_Book__c)?exisprodToLPMap.get(''+lp.core_cpq_product_name__c+lp.core_cpq_Price_Book__c):new List<core_cpq_list_price__c>();
                lpList.add(lp);
                exisprodToLPMap.put(''+lp.core_cpq_product_name__c+lp.core_cpq_Price_Book__c,lpList);
            }
        }
        Map<String,PricebookEntry> newProdTOPBEMap= new Map<String,PricebookEntry>();
        List<core_cpq_list_price__c> newlpToUpsert = new List<core_cpq_list_price__c>();
        for(Product3__c prod:prodList){
            string uniqueValue = '';
            if(opnProdMap.containsKey(prod.Core_OPN__c) && prodToPBEMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){
                for(PricebookEntry pbe:prodToPBEMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){
                    //if(prodToExisPBMap.containsKey(prod.Id) && prodToExisPBMap.get(prod.Id).contains(pbe.Pricebook2Id)){
                    if(!prodToExisPBMap.containsKey(prod.Id)){
                        /*if(exisprodToPBEMap.containsKey(prod.Id+'_'+pbe.Pricebook2Id)){
                        PriceBookEntry pbe1=exisprodToPBEMap.get(prod.Id+'_'+pbe.Pricebook2Id);
                        pbe1.UnitPrice=pbe.UnitPrice;
                        pbe1.price_disty_cost__c=pbe.price_disty_cost__c;
                        pbe1.core_cpq_minimum_order_qty__c=pbe.core_cpq_minimum_order_qty__c;
                        pbe1.core_cpq_multiple_order_quantity__c=pbe.core_cpq_multiple_order_quantity__c;
                        uniqueValue = ''+ pbe1.Product3__cId + pbe1.Pricebook2Id;
                        pbe1.core_cpq_unique_id__c = uniqueValue.trim();
                        if(!pbe1.UseStandardPrice){
                        pbeListToUpdate.add(pbe1);
                        }                            
                        newProdTOPBEMap.put(''+ pbe1.Product3__cId + pbe1.Pricebook2Id,pbe1);
                        }
                    }else{*/
                        PricebookEntry newpbe=new PricebookEntry();
                        newpbe.PriceBook2Id=pbe.PriceBook2Id;
                        newpbe.UnitPrice=pbe.UnitPrice;
                        newpbe.price_disty_cost__c=pbe.price_disty_cost__c;
                        newpbe.core_cpq_minimum_order_qty__c=pbe.core_cpq_minimum_order_qty__c;
                        newpbe.core_cpq_multiple_order_quantity__c=pbe.core_cpq_multiple_order_quantity__c;
                        uniqueValue = ''+prod.Id + pbe.Pricebook2Id;
                        newpbe.core_cpq_unique_id__c = uniqueValue.trim();
                        newpbe.Product3__c=prod.Id;
                        newpbe.IsActive=true;
                        if(pbe.PriceBook2.Name==Label.PSG_DefaultPricebookName){
                            spbeListToInsert.add(newpbe);
                        }else{
                            pbeListToInsert.add(newpbe);
                        }
                        newProdTOPBEMap.put(''+ prod.Id + pbe.Pricebook2Id,newpbe);
                    }
                }
            }
            /*if(opnProdMap.containsKey(prod.Core_OPN__c) && prodToPFCMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){
            for(price_forward_cost__c pfc:prodToPFCMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){
            if(!newProdToExisFCMap.containsKey(prod.Id)){
            price_forward_cost__c newPfc=pfc.clone(false,false,false,false);
            newPfc.core_cpq_product_nm__c=prod.Id;
            newPfc.core_cpq_unique_id__c = newPfc.Name + String.ValueOf(prod.Id);
            pfcListToInsert.add(newPfc);
            }                    
            }
            }*/
            
            if(opnProdMap.containsKey(prod.Core_OPN__c) && prodToMSVPMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){
                for(price_msvp__c msvp:prodToMSVPMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){
                    if(!newProdToExisMSVPMap.containsKey(prod.Id)){
                        price_msvp__c newMsvp=msvp.clone(false,false,false,false);
                        newMsvp.core_cpq_product_nm__c=prod.Id;
                        newMsvp.core_cpq_unique_id__c=''+prod.Id+msvp.core_cpq_effective_date_dt__c;
                        msvpListToInsert.add(newMsvp);
                    }
                }
            }
        }
        if(!spbeListToInsert.isEmpty()){ 
            insert spbeListToInsert;
        }
        if(!pbeListToInsert.isEmpty()){ 
            insert pbeListToInsert;
        }
        /*if(!pbeListToUpdate.isEmpty()){
        update pbeListToUpdate;
        }*/
        
        for(Product3__c prod:prodList){
            if(opnProdMap.containsKey(prod.Core_OPN__c)){
                for(String key : newProdTOPBEMap.keyset()){
                    if(key.contains(''+prod.Id) && newProdTOPBEMap.get(key).Id != null){
                        PricebookEntry pbe=newProdTOPBEMap.get(key);
                        if(exisprodToLPMap.containsKey(''+opnProdMap.get(prod.Core_OPN__c).Id+pbe.Pricebook2Id)){
                            List<core_cpq_list_price__c> exisLP=exisprodToLPMap.get(''+opnProdMap.get(prod.Core_OPN__c).Id+pbe.Pricebook2Id);
                            for(core_cpq_list_price__c lp : exisLP){
                                if(!newProdToExisLPMap.containsKey(prod.Id)){
                                    core_cpq_list_price__c newLP=lp.clone(false,false,false,false);
                                    newLP.Pricebookentry__c=pbe.Id;
                                    newLP.core_cpq_product_name__c=prod.Id;
                                    newLP.core_cpq_Price_Book__c=pbe.Pricebook2Id;
                                    newLP.core_cpq_unique_id__c=''+lp.core_cpq_lowerbound_qty__c+'.0'+lp.core_cpq_upperbound_qty__c+'.0'+prod.Id+pbe.Id;
                                    newlpToUpsert.add(newLP);
                                }                                
                            }
                        }
                    }
                }
            }
        }
        
        if(!newlpToUpsert.isEmpty()){
            List<core_cpq_list_price__c> failedRec=new List<core_cpq_list_price__c>();
            Database.UpsertResult[] result=Database.upsert(newlpToUpsert,core_cpq_list_price__c.core_cpq_unique_id__c,false);
            for(Integer i=0;i<result.size();i++){
                if (!result[i].isSuccess()) {
                    failedRec.add(newlpToUpsert[i]);
                }
            }
            if(failedRec.size()>0){
                PSG_Utility.createCoreLogEntry('PSG_Product3BusinessLogic','changeProductOnRelatedObjects','Error while Copying List Price records.','Failed Records : \n '+failedRec+'\n\n Database SaveResult : '+result,'Product','Low','');
            }
        }
        
        /*if(!pfcListToInsert.isEmpty()){
        List<price_forward_cost__c> failedRec=new List<price_forward_cost__c>();
        Database.UpsertResult[] result=Database.upsert(pfcListToInsert,price_forward_cost__c.core_cpq_unique_id__c,false);
        for(Integer i=0;i<result.size();i++){
        if (!result[i].isSuccess()) {
        failedRec.add(pfcListToInsert[i]);
        }
        }
        if(failedRec.size()>0){
        PSG_Utility.createCoreLogEntry('PSG_Product3BusinessLogic','changeProductOnRelatedObjects','Error while Copying Forward cost records.','Failed Records : \n '+failedRec+'\n\n Database SaveResult : '+result,'Product','Low','');
        }
        }*/
        if(!msvpListToInsert.isEmpty()){
            List<price_msvp__c> failedRec=new List<price_msvp__c>();
            Database.UpsertResult[] result=Database.upsert(msvpListToInsert,price_msvp__c.core_cpq_unique_id__c,false);
            for(Integer i=0;i<result.size();i++){
                if (!result[i].isSuccess()) {
                    failedRec.add(msvpListToInsert[i]);
                }
            }
            if(failedRec.size()>0){
                PSG_Utility.createCoreLogEntry('PSG_Product3BusinessLogic','changeProductOnRelatedObjects','Error while Copying MSVP records.','Failed Records : \n '+failedRec+'\n\n Database SaveResult : '+result,'Product','Low','');
            }
        }
    }
    public static Map<String,String> getRecentActivatedProduct(Set<String> opnSet,List<Product3__c> newList){
        Map<String,String> opnToExisProdIdMap=new Map<String,String>();
        for(Product3__c prod : [Select id,core_OPN__c from Product3__c where core_OPN__c in :opnSet and Core_Product_org__c = 'Sales' and Core_Product_Type__c = :Label.PSG_Product_Type_Identifier and Id not in :newList  order by CreatedDate  desc]){
            if(!opnToExisProdIdMap.containsKey(prod.core_OPN__c)){
                opnToExisProdIdMap.put(prod.core_OPN__c,prod.Id);
            } 
        }
        /*for(Product3__cHistory prodHis : [Select id,OldValue, NewValue,Product3__cId,Product3__c.core_OPN__c from Product3__cHistory where Field ='IsActive' and Product3__c.core_OPN__c in :opnSet and Product3__c.core_OPN__c not in :opnToExisProdIdMap.keyset() and  Product3__c.Core_Product_org__c = 'Sales' and Product3__c.Core_Product_Type__c = :Label.PSG_Product_Type_Identifier and Product3__cId not in :newList  order by CreatedDate  desc]){
            if(!opnToExisProdIdMap.containsKey(prodHis.Product3__c.core_OPN__c) && prodHis.NewValue == false){
                opnToExisProdIdMap.put(prodHis.Product3__c.core_OPN__c,prodHis.Product3__cId);
            } 
        }*/
        return opnToExisProdIdMap;
    }
    // added from Core_PSG_ActiveProductExtAttrHandler
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
                        releaseProdList.add(prod);
                        opnSet.add(prod.Core_OPN__c);
                    }
                }
            }
        }               
        
        if(!opnSet.isEmpty() || opnSet!=null){
            //take the Active latest pre release product based on Createddate. There could be multiple inactive, hence added Order By createdDate
            // Map<String,String>
            recentActiveProdMap = getRecentActivatedProduct(opnSet,releaseProdList);
            for(Product3__c prodRec: [SELECT Id,Core_OPN__c from Product3__c WHERE Id in :recentActiveProdMap.values()]){  	
                preReleaseProdList.add(prodRec);
                if(!opnProdMap.containsKey(prodRec.Core_OPN__c)){
                    opnProdMap.put(prodRec.Core_OPN__c,prodRec);
                }
            }
        }
        
        /*if(!opnProdMap.isEmpty()){ 
        	List<Product3__c> extendedAttributeList = opnProdMap.values();
            for(Core_Product_Ext_Attribute__c preReleaseExtAttr: [select Id,Core_Product_Id__c,Core_SW_Prod_Additional_Dsc__c,Core_Prod_QTE_Alt_LGSTS_NW_Enabled_Ind__c,Core_SW_Lic_Authorization_Cd__c,Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c,Core_SW_Lic_Companion_Ind__c,
            Core_SW_Lic_File_Data_Encryption_Std_Cd__c,Core_SW_Lic_Enforcement_Method_Nm__c,Core_Foundation_Product_Id__c,Core_SW_Lic_Comment_Txt__c,Core_SW_Lic_Group_Id__c,Core_SW_Lic_Generator_Parameter_Txt__c,
            Core_SW_Lic_Linux_Download_URL_Txt__c,Core_SW_Prod_Max_Rehost_Cnt__c,Core_SW_Prod_Non_Commercial_Purpose_Nm__c,Core_SW_Prod_Expiration_Duration_Nbr__c,
            Core_SW_Lic_Rehostable_Ind__c,Core_SW_Lic_Renewal_Period_Nbr__c,Core_Prod_QTE_Slow_Moving_Inventory_Ind__c,Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Core_SW_Lic_Type_Nm__c,Core_Prod_Tool_Type_Nm__c,
            Core_SW_Prod_Web_Dsc__c,Core_SW_Lic_Web_Displayable_Ind__c,Core_SW_Lic_Windows_Download_URL_Txt__c, PSG_Restricted_Product__c
            from Core_Product_Ext_Attribute__c where Core_Product_Id__c in:extendedAttributeList]){
                List<Core_Product_Ext_Attribute__c> preReleaseExtAttrList=existingPreReleaseExtAttrMap.containsKey(preReleaseExtAttr.Core_Product_Id__c)?existingPreReleaseExtAttrMap.get(preReleaseExtAttr.Core_Product_Id__c):new List<Core_Product_Ext_Attribute__c>();
                preReleaseExtAttrList.add(preReleaseExtAttr);
                existingPreReleaseExtAttrMap.put(preReleaseExtAttr.Core_Product_Id__c,preReleaseExtAttrList); 
            }
        }*/
        
        for(Product3__c prod:releaseProdList){ 
            if(opnProdMap.containsKey(prod.Core_OPN__c) && existingPreReleaseExtAttrMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){                               
                //Clone the extended Attributes from Pre release to release products
                for(Core_Product_Ext_Attribute__c prodExtAttrAct:existingPreReleaseExtAttrMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){                  
                    Core_Product_Ext_Attribute__c extAttrToInsert = new Core_Product_Ext_Attribute__c();
                    extAttrToInsert.Core_Product_Id__c =prod.Id;
                    extAttrToInsert.Core_SW_Prod_Additional_Dsc__c=prodExtAttrAct.Core_SW_Prod_Additional_Dsc__c;
                    extAttrToInsert.PSG_Restricted_Product__c=prodExtAttrAct.PSG_Restricted_Product__c; // added by soundarya
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
                captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Error while Copying Signal Code and Product Class records to Active Products:'+failedRec, Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSG_ActiveProductExtAttrHandler', Core_When__c = System.now())); 
            }
        }
        updateSignalCodeOnAllProducts( newList,oldMap,  recentActiveProdMap);             
    } 
    // added from Core_PSG_ActiveProductExtAttrHandler
    public static void updateSignalCodeOnAllProducts(List<Product3__c> newList,Map<Id,Product3__c> oldMap, Map<String,String> recentActiveProdMap){
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
                if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.Core_OPN__c!=null && prod.IsActive__c &&  prod.Core_Product_Org__c=='Sales' ){
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
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Error while Copying Signal Code and Product Class records to All Products' + e.getStackTraceString() + e.getMessage(), Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSG_ActiveProductExtAttrHandler', Core_When__c = System.now())); 
        }
        finally
        {
            // insert captureQueryErr;
        }      
    }
    // added from Core_PSG_Change_Sales_Status
    Public static void updateSalesStatus(List<Product3__c> updatedProductList, Map<Id,Product3__c> oldMap){
        try{           
            
            final String TOOL = 'Tool';
            final String COMPONENT = 'Component';
            final String STATUSCODE_AC = 'AC';
            List<Product3__c> productsToUpdate = new List<Product3__c>();
            
            //Get all metadata into map-ex: <AC, (orderable,shippable,quotable,priceauth)>  
            Map<String, Core_PSG_Product_Status_Code_Mapping__mdt> productSignalStatusCodeMetadataMap = new Map<String, Core_PSG_Product_Status_Code_Mapping__mdt>();
            List<Core_PSG_Product_Status_Code_Mapping__mdt> productSignalStatusCodeMetadataList = [SELECT Id,DeveloperName,QualifiedApiName,Status_Code__c,Quotable__c, Orderable__c, Shippable__c,Price_Auth__c FROM Core_PSG_Product_Status_Code_Mapping__mdt WITH SECURITY_ENFORCED];
            for(Core_PSG_Product_Status_Code_Mapping__mdt productSignalStatusCodeMetadata: productSignalStatusCodeMetadataList){
                productSignalStatusCodeMetadataMap.put(productSignalStatusCodeMetadata.Status_Code__c, productSignalStatusCodeMetadata);
            }
            
            //Map products based on statusCode:ex: <AC, (productrecorddetails)>
            Map<String, Product3__c> statusCodeProductMap = new Map<String, Product3__c>();
            
            for(Product3__c updatedProduct: updatedProductList){ //Iterate all Products
                if(oldMap==null){//After Insert
                    if(updatedProduct.Core_Product_Type_Nm__c==TOOL){//Tool Product
                        statusCodeProductMap.put(updatedProduct.Core_Product_Status__c+updatedProduct.Id, updatedProduct);
                    }
                    else if(updatedProduct.Core_Product_Type_Nm__c==COMPONENT){//Component Product
                        statusCodeProductMap.put(updatedProduct.Core_Item_Signal_Cd__c+updatedProduct.Id, updatedProduct);
                    }
                }
                else if(oldMap!=null && oldMap.size()>0 && oldMap.get(updatedProduct.Id).Core_Item_Signal_Cd__c !=updatedProduct.Core_Item_Signal_Cd__c || 
                        oldMap.get(updatedProduct.Id).Core_Product_Status__c !=updatedProduct.Core_Product_Status__c ||
                        oldMap.get(updatedProduct.Id).Core_Item_Class_Nm__c != updatedProduct.Core_Item_Class_Nm__c
                       ){  //After Update and if Value has changed
                           if(updatedProduct.Core_Product_Type_Nm__c==TOOL){//Tool Product
                               statusCodeProductMap.put(updatedProduct.Core_Product_Status__c+updatedProduct.Id, updatedProduct);
                           }
                           else if(updatedProduct.Core_Product_Type_Nm__c==COMPONENT){//Component Product
                               statusCodeProductMap.put(updatedProduct.Core_Item_Signal_Cd__c+updatedProduct.Id, updatedProduct);
                           }
                           else{//If Product Type is null and (Product Status or Signal Code is null)
                               statusCodeProductMap.put(updatedProduct.Id, updatedProduct);
                           }
                       }
            }
            
            //Iterate through Map and update each product record as per metadata values
            for(String statusCode : statusCodeProductMap.keySet()){
                Product3__c product=null;
                String statusCodeSubString=statusCode.substring(0, 2);
                Core_PSG_Product_Status_Code_Mapping__mdt statusCodeDetails=null;
                if(statusCodeProductMap.containsKey(statusCode))
                {
                    product= statusCodeProductMap.get(statusCode); //Product To Update
                }           	
                if(productSignalStatusCodeMetadataMap.containsKey(statusCodeSubString)){
                    statusCodeDetails = productSignalStatusCodeMetadataMap.get(statusCodeSubString);
                }
                Product3__c updateProductStatusCode = new Product3__c();
                if(statusCodeDetails!=null){                    
                    updateProductStatusCode.Core_Item_Orderable_Ind__c=statusCodeDetails.Orderable__c;
                    updateProductStatusCode.Core_Item_Shippable_Ind__c = statusCodeDetails.Shippable__c;
                    updateProductStatusCode.Core_Item_Quotable_Ind__c= statusCodeDetails.Quotable__c;
                    updateProductStatusCode.Core_Item_Price_Authorization_Ind__c = statusCodeDetails.Price_Auth__c;
                    updateProductStatusCode.Id = product.Id;
                    
                    if(product.Core_Product_Type_Nm__c==TOOL){ //Core_Item_Price_Authorization_Ind__c is not used for TOOL product, so it remains false for TOOL Product
                        updateProductStatusCode.Core_Item_Price_Authorization_Ind__c = False;
                    }
                    productsToUpdate.add(updateProductStatusCode);
                }else{//If Status Code is not found then set false
                    updateProductStatusCode.Core_Item_Orderable_Ind__c=False;
                    updateProductStatusCode.Core_Item_Shippable_Ind__c = False;
                    updateProductStatusCode.Core_Item_Quotable_Ind__c= False;
                    updateProductStatusCode.Core_Item_Price_Authorization_Ind__c = False;
                    updateProductStatusCode.Id = product.Id;
                    productsToUpdate.add(updateProductStatusCode);
                }         
            }
            if(productsToUpdate.size()>0 && Product3__c.SObjectType.getDescribe().isUpdateable()){
                update productsToUpdate;
            }
        }
        catch(Exception ex){
            system.debug('#ex1:'+ex.getLineNumber());
            system.debug('#ex2:'+ex.getMessage());
        }                
    }
    // added from Core_UpdateEOLOppProd
    public static void updateEOLonUpdate(List<Product3__c> newList,Map<Id, Product3__c> prodOldMap){
        system.debug('in updateEOLonUpdate');
        List<Product3__c> prodList = new List<Product3__c>();
        for(Product3__c p : newList){
            if(p.Core_SA_Is_EOL__c <> prodOldMap.get(p.Id).Core_SA_Is_EOL__c ){
                prodList.add(p);
            }
        }
        if(prodList.size()>0){
            callBatch(prodList);
        }
    }
    public static void callBatch(List<Product3__c> newList){        
        //database.executeBatch(new Core_Batch_updateEOL(newList),integer.valueof(system.label.Core_Batch_updateEOL_BatchSize));
    }
    
    //added from Core_PSG_Change_Sales_Status
    public static void SendUpdatedProductstoOrders(List<Product3__c> newProductList, Map<Id, Product3__c> oldProdMap){
        List<Product3__c> ProdLst= new List<Product3__c>();
        for(Product3__c prodRec : newProductList){
            //if(prodRec.SBQQ__SubscriptionPricing__c != oldProdMap.get(prodRec.Id).SBQQ__SubscriptionPricing__c ||prodRec.SBQQ__SubscriptionType__c != oldProdMap.get(prodRec.Id).SBQQ__SubscriptionType__c){            
            ProdLst.add(prodRec);              
            //}            
        }         
        if(ProdLst.size()>0){
            system.debug('*****&ProdLst'+ProdLst);
            updateProductDetails_OrderproductSubscription(ProdLst);
        }
    }
    // added from Sales_UpdateProductDetails
    public static void updateProductDetails_OrderproductSubscription(List<Product3__c> productList){
        set<Id> productId= new Set<Id>();
        for(Product3__c prod : productList){
            productId.add(prod.Id);
        }
        //calling queueable job to process the records
        //System.enqueueJob(new upadateProductDetailsOnOrderproductSubscription(productId));
    }
    //added from Core_ProductOpportunity
    public static void updateProcessorNumber(List<Product3__c> newProductList){
        String substr='';
        for(Product3__c prod : newProductList){
            /*if(prod.Core_Processor_Number_Nm__c !='' && prod.Core_Product_Type__c == 'Processors'){
                prod.Core_Processor_Number_Nm__c = prod.Core_Processor_Number_Nm__c;    
                }
                else{
                prod.Core_Processor_Number_Nm__c = '';   
            }*/
            //Gireesh:US845281:Copy 255 chars from new Processor Number(Core_Processor_Number_Ta_Nm__c)  to old Processor(Core_Processor_Number_Nm__c)
            if(prod.Core_Processor_Number_Ta_Nm__c !=''  && (prod.Core_Product_Type__c == 'Processors' || prod.Core_Product_Type__c == 'Partnered Products')){
                prod.Core_Processor_Number_Ta_Nm__c = prod.Core_Processor_Number_Ta_Nm__c;
                substr=prod.Core_Processor_Number_Ta_Nm__c;
                if(prod.Core_Processor_Number_Ta_Nm__c!=Null && (prod.Core_Processor_Number_Ta_Nm__c).length()>=255){
                    substr= prod.Core_Processor_Number_Ta_Nm__c.substring(0,255);
                }
                prod.Core_Processor_Number_Nm__c=substr;    
            }
            else{
                prod.Core_Processor_Number_Ta_Nm__c = ''; 
                prod.Core_Processor_Number_Nm__c='';
            }            
        }               
    }
    // added from Core_PSG_ActiveProductExtAttrHandler
    public static void removeSignalCodeUpdatedProducts(List<Product3__c> newProductList, Map<Id,Product3__c> oldProductMap){
        
        List<Product3__c> signalCodeUnchangedProdList = new List<Product3__c>();
        for (Product3__c prod : newProductList){
            if(!(prod.Core_Item_Signal_Cd__c != oldProductMap.get(prod.Id).Core_Item_Signal_Cd__c)){
                
                signalCodeUnchangedProdList.add(prod);
            }
        }
        
        if(!signalCodeUnchangedProdList.isEmpty()){
            //Commented as part of Signal Code FIX
            //Core_PSG_ActiveProductExtAttrHandler.updateSignalCodeOnActiveProduct(signalCodeUnchangedProdList); 
            updateSignalCodeOnAllProducts(signalCodeUnchangedProdList,oldProductMap,new Map<String,String>()); 
        }       
    }
    //added from PSG_ActiveProductExtAttrHandler
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
                    //prodRecSignalCode.Core_Item_Price_Authorization_Ind__c = existingProdWithSignalCodeMap.get(prodRecSignalCode.Core_OPN__c).Core_Item_Price_Authorization_Ind__c;
                    prodWithoutSignalCodeMapUpdate.add(prodRecSignalCode);
                }
            }
            
            // update prodWithoutSignalCodeMapUpdate;
            recursiveCheckSignalCode = false;   
        }    
    }
}