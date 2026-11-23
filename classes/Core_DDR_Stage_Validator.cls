/****************************************************************************************************
Apex Class Name : Core_DDR_Stage_Validator
Version         : 1.0 
Created Date    : 10/12/2017
Function        : This class is to used to segregate the Design and product from design stage record, validate the records and create the respective records and log the errors(If any) in design registration stage 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Team Accenture              10/12/2017            Created
*****************************************************************************************************/

public Class Core_DDR_Stage_Validator
{
    public Core_DDR_Stage_Validator()
    {

    }

    public Boolean checkIsUSDatePattern(String DateValue)
    {
        String dateRegEx = '(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)';
        Pattern myPattern = Pattern.compile(dateRegEx);
        Matcher myMatcher = myPattern.matcher(DateValue);
        if(myMatcher.matches())
        {
            return TRUE;   
        }
        else
        {
            return FALSE;   
        }    
    }
    public void checkValidations(List<Core_Design_Registration_Stage__c> lstDesignRegStage)
    {
        List<Core_Design_Registrations_Bulk_Upload__c> lstBulkUploadMappings = [SELECT id, Name, Core_Active_Ind__c, 
            Core_CSV_Column_Nm__c, Core_Design_API_Field_Nm__c, Core_Design_Required_Ind__c, 
            Core_Field_Data_Type_Txt__c, Core_Header_Or_Product_Ind__c, Core_Stage_API_Field_Nm__c, 
            Core_Stage_Required_Ind__c FROM Core_Design_Registrations_Bulk_Upload__c 
            WHERE Core_Active_Ind__c = TRUE];
            
        List<Core_Design_Registration_Stage__c> lstUpdateDesignRegStg = new List<Core_Design_Registration_Stage__c>();
        List<Core_Design_Registration_Stage__c> lstDesignRegStgForIns = new List<Core_Design_Registration_Stage__c>();

        for(Core_Design_Registration_Stage__c iDesignRegStg : lstDesignRegStage)
        {
        
            //Iterating all the fields for checking the required field is filled or not. Records which have all the required fields will be send to creation method
            for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
            {
            
                if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Product' && iDesignRegStg.get('Core_Design_Registration_Line_ID__c') == '')
                {
                    if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Design_Required_Ind__c == TRUE && (iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) == ''))
                    {
                        iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                        
                        if(iDesignRegStg.Core_Message_Txt__c == null)
                        {
                            iDesignRegStg.Core_Message_Txt__c = 'Required field missing: '+ iBU.Core_CSV_Column_Nm__c ;
                        }
                        else
                        {
                            iDesignRegStg.Core_Message_Txt__c +=  ', '+iBU.Core_CSV_Column_Nm__c ;
                        }
                    }
                    
                    if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Number' && (!((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c)).isNumeric()))
                    {
                        iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                        
                        if(iDesignRegStg.Core_Message_Txt__c == null)
                        {
                            iDesignRegStg.Core_Message_Txt__c = 'Invalid number value for number field: '+ iBU.Core_CSV_Column_Nm__c ;
                        }
                        else
                        {
                            iDesignRegStg.Core_Message_Txt__c +=  ', '+iBU.Core_CSV_Column_Nm__c ;
                        }                        
                    }

                    if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Date' && (!checkIsUSDatePattern((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c))))
                    {
                        iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                        
                        if(iDesignRegStg.Core_Message_Txt__c == null)
                        {
                            iDesignRegStg.Core_Message_Txt__c = 'Please provide the date with the format MM/DD/YYYY : '+ iBU.Core_CSV_Column_Nm__c ;                            
                        }
                        else
                        {
                            iDesignRegStg.Core_Message_Txt__c +=  ', '+iBU.Core_CSV_Column_Nm__c ;
                        }                     
                    }                  
                }
                else if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Header' && iDesignRegStg.get('Core_Registration_Number_Id__c') == '')
                {
                    if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Design_Required_Ind__c == TRUE && (iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) == ''))
                    {
                        iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                        
                        if(iDesignRegStg.Core_Message_Txt__c == null)
                        {
                            iDesignRegStg.Core_Message_Txt__c = 'Required field missing: '+ iBU.Core_CSV_Column_Nm__c ;
                        }
                        else
                        {
                            iDesignRegStg.Core_Message_Txt__c +=  ', '+iBU.Core_CSV_Column_Nm__c ;
                        }
                    }
                    
                    if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Number' && (!((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c)).isNumeric()))
                    {
                        iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                        
                        if(iDesignRegStg.Core_Message_Txt__c == null)
                        {
                            iDesignRegStg.Core_Message_Txt__c = 'Invalid number value for number field: '+ iBU.Core_CSV_Column_Nm__c ;
                        }
                        else
                        {
                            iDesignRegStg.Core_Message_Txt__c +=  ', '+iBU.Core_CSV_Column_Nm__c ;
                        }                        
                    }
                                     
                    if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Date' && (!checkIsUSDatePattern((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c))))
                    {
                        iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                        
                        if(iDesignRegStg.Core_Message_Txt__c == null)
                        {
                            iDesignRegStg.Core_Message_Txt__c = 'Please provide the date with the format MM/DD/YYYY : '+ iBU.Core_CSV_Column_Nm__c ;                            
                        }
                        else
                        {
                            iDesignRegStg.Core_Message_Txt__c +=  ', '+iBU.Core_CSV_Column_Nm__c ;
                        }                     
                    }                        
                                        
                }
            }    
        }
        
        for(Core_Design_Registration_Stage__c iDesignRegStg : lstDesignRegStage)
        {
            if(iDesignRegStg.Core_Processing_Status_Nm__c == 'Failed')
            {
                lstUpdateDesignRegStg.add(iDesignRegStg);
            }
            else
            {
                lstDesignRegStgForIns.add(iDesignRegStg);
            }
        }
        
        update lstUpdateDesignRegStg;
        
        //To create the DR & DRLI records 
        createDesignReg(lstDesignRegStgForIns);
        
    }
    
    //To retrieve users associated with the loggedin user's partner contact and users belongs to the same partner Account.
    private Map<Id, Boolean> getMapLoggedUserPartnerContacts()
    {
    
        User loggedInUser = [SELECT Id, Name, AccountId FROM User WHERE ID =: UserInfo.getUserId()];
        List<Contact> lstContact = [SELECT Id, Email FROM Contact WHERE AccountId =: loggedInUser.AccountId];    
        List<User> lstUser = [SELECT Id, ContactID FROM User WHERE ContactId IN: lstContact];
        Map<Id, Boolean> mapLoggedInUserAccountRelatedUserIds = new Map<Id, Boolean>();
        
        for(User iUser : lstUser)
        {
            mapLoggedInUserAccountRelatedUserIds.put(iUser.Id, TRUE);    
        }
        
        return mapLoggedInUserAccountRelatedUserIds;
    }
      
    public void createDesignReg(List<Core_Design_Registration_Stage__c> lstDRStages)
    {
        Map<String, Core_Design_Registration__c> mapGrpIdTODesignReg = new Map<String, Core_Design_Registration__c>();
        Map<String, List<Core_Design_Registration_Product__c>> mapGrpIdTODesignRegProd = new Map<String, List<Core_Design_Registration_Product__c>>();
        Map<String, String> mapHeadGrpIdTODesignStgId = new Map<String, String>();
        Map<String, String> mapDesignStgIdTODesignRegId = new Map<String, String>();
        Map<String, String> mapDesignRegIdTODesignStgId = new Map<String, String>();
        Map<String, String> mapDesignRegIdTODesignRegName = new Map<String, String>();
        Map<String, String> mapDesignRegProdIdTODesignStgId = new Map<String, String>();
        Map<String, String> mapDesignRegProdIdTODesignProdName = new Map<String, String>();
        Map<String, String> mapProductNameToProductId = new Map<String, String>();
        Map<Id, Boolean> mapLoggedInUserAccountRelatedUserIds = new Map<Id, Boolean>();

        
        List<Core_Design_Registrations_Bulk_Upload__c> lstBulkUploadMappings = [SELECT id, Name, Core_Active_Ind__c, 
            Core_CSV_Column_Nm__c, Core_Design_API_Field_Nm__c, Core_Design_Required_Ind__c, 
            Core_Field_Data_Type_Txt__c, Core_Header_Or_Product_Ind__c, Core_Stage_API_Field_Nm__c, 
            Core_Stage_Required_Ind__c FROM Core_Design_Registrations_Bulk_Upload__c 
            WHERE Core_Active_Ind__c = TRUE];
        List<Core_Design_Registration__c> lstInsertDesign = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration_Product__c> lstProcessDesignProduct = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Stage__c> lstUpdateDesignRegStg = new List<Core_Design_Registration_Stage__c>();
        
        Set<Id> setDesignRegSuccessIds = new Set<Id>();
        Set<Id> setDesignRegFailedStageRecIds = new Set<Id>();
        Map<id,String> mapDesignRegFailedStageRecIdsAndErrMsg = new Map<id,String>();
        Set<Id> setDesignRegProdFailedStageRecIds = new Set<Id>();
        Set<Id> setDesignRegProdSuccessIds = new Set<Id>();
        Set<String> setProductNames = new Set<String>();
        Set<String> setUsrEmailIds = new Set<String>();
        Map<String,Id> mapAllActiveUsrsEmailAndIds = new Map<String,Id>();
        Map<Id, Core_Design_Registration_Stage__c> mapUpdateDRStg = new Map<Id, Core_Design_Registration_Stage__c>();
       
        for(Core_Design_Registration_Stage__c DRSObj : lstDRStages)
        {
            setUsrEmailIds.add(DRSObj.Core_Owner_Txt__c);
            
            setProductNames.add(DRSObj.Core_Product_Id__c);
        }
        
        if(setUsrEmailIds.size() > 0)
        {
            for(User usrObj : [SELECT Id,email, Name,IsActive FROM User WHERE email IN: setUsrEmailIds And IsActive=true]) 
            {
                mapAllActiveUsrsEmailAndIds.put(usrObj.email, usrObj.id);
            }
        }
       
        if(setProductNames.size() > 0)
        {
            for(Product2 iProd : [SELECT id, Name From Product2 WHERE  Name IN: setProductNames AND Core_Design_Registration_Eligible_Ind__c = TRUE AND isActive = TRUE AND Core_Sales_Visible_Flag__c = TRUE])
            {
                mapProductNameToProductId.put(iProd.Name, iProd.Id);
            }
        }
       
        //Get the map of user Id to whom the logged In user can upload the design registrations   
        mapLoggedInUserAccountRelatedUserIds = getMapLoggedUserPartnerContacts();
        
        for(Core_Design_Registration_Stage__c iDRS : lstDRStages)
        {
            Core_Design_Registration__c designReg = new Core_Design_Registration__c ();
            Core_Design_Registration_Product__c designRegProd = new Core_Design_Registration_Product__c();
            
            //Field value assignment for Design Registration Header record 
            if(iDRS.Core_Header_Or_Product_Ind__c == 'Header')
            {
                mapHeadGrpIdTODesignStgId.put(iDRS.Core_Group_Id__c, iDRS.Id);

                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    designReg.put('Core_Design_Registration_Stage_Id__c', iDRS.get('Id'));
                
                    if(iBU.Core_Stage_API_Field_Nm__c != NULL && iBU.Core_Stage_API_Field_Nm__c != '' && iBU.Core_Design_API_Field_Nm__c != NULL && iBU.Core_Design_API_Field_Nm__c != '' && iBU.Core_Header_Or_Product_Ind__c == 'Header')
                    {
                      System.debug('iBU.Core_Stage_API_Field_Nm__c==>'+iBU.Core_Stage_API_Field_Nm__c);
                    
                        if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != NULL)
                        {
                            if(iBU.Core_Field_Data_Type_Txt__c == 'Number' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                designReg.put(iBU.Core_Design_API_Field_Nm__c, decimal.ValueOf((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)));
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Checkbox' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                if(((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)).toUpperCase().contains('YES') || ((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)).toUpperCase().contains('Y'))
                                {
                                    designReg.put(iBU.Core_Design_API_Field_Nm__c, TRUE);
                                }
                                else if(((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)).toUpperCase().contains('NO') || ((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)).toUpperCase().contains('N'))
                                {
                                    designReg.put(iBU.Core_Design_API_Field_Nm__c, FALSE);
                                }
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Text')
                            {
                                designReg.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c));
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Date' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                designReg.put(iBU.Core_Design_API_Field_Nm__c, date.ValueOf(Date.parse((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c))));    
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'ID' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                if(iBU.Core_Stage_API_Field_Nm__c == 'Core_Owner_Txt__c' )
                                {
                                        designReg.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c)); 
                                }   
                            } // close else if
                            
                        }
                    }
                }
                
                mapGrpIdTODesignReg.put(iDRS.Core_Group_Id__c, designReg);    

            } // close if(iDRS.Core_Header_Or_Product_Ind__c == 'Header')
            
            //Field value assignment for Design Registration Product record 
            if(iDRS.Core_Header_Or_Product_Ind__c == 'Product')
            {
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    designRegProd.put('Core_Design_Registration_Stage_Id__c', iDRS.get('Id'));
                    
                    if(iBU.Core_Stage_API_Field_Nm__c != NULL && iBU.Core_Stage_API_Field_Nm__c != '' && iBU.Core_Design_API_Field_Nm__c != NULL && iBU.Core_Design_API_Field_Nm__c != '' && iBU.Core_Header_Or_Product_Ind__c == 'Product')
                    {
                        if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != NULL)
                        { 
                            if(iBU.Core_Field_Data_Type_Txt__c == 'Number' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                designRegProd.put(iBU.Core_Design_API_Field_Nm__c, decimal.ValueOf((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)));
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Checkbox' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'Y' || iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'Yes')
                                {
                                    designReg.put(iBU.Core_Design_API_Field_Nm__c, 'TRUE');
                                }
                                else if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'N' || iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'No')
                                {
                                    designReg.put(iBU.Core_Design_API_Field_Nm__c, 'FALSE');
                                }
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Text')
                            {
                                designRegProd.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c));
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Date' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                designRegProd.put(iBU.Core_Design_API_Field_Nm__c, date.ValueOf(Date.parse((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c))));    
                            }   
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Lookup' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                
                                if(iBU.Core_Design_API_Field_Nm__c == 'Core_Product_Id__c')
                                {
                                    designRegProd.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c));
                                }
                            } 
                            else if (iBU.Core_Field_Data_Type_Txt__c == 'Picklist' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'Y' || iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'Yes')
                                {
                                     designRegProd.put(iBU.Core_Design_API_Field_Nm__c, 'Cancelled');
                                } 
                            }                    
                        }
                    }
                } // close for  for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                
                
                if(!mapGrpIdTODesignRegProd.containskey(iDRS.Core_Group_Id__c))
                {
                    mapGrpIdTODesignRegProd.put(iDRS.Core_Group_Id__c, new List<Core_Design_Registration_Product__c>{});
                }
                
                List<Core_Design_Registration_Product__c> lstTdesignRegProd = mapGrpIdTODesignRegProd.get(iDRS.Core_Group_Id__c);
                lstTdesignRegProd.add(designRegProd);
                
                mapGrpIdTODesignRegProd.put(iDRS.Core_Group_Id__c, lstTdesignRegProd);    

            }    // close    if(iDRS.Core_Header_Or_Product_Ind__c == 'Product')
                
            
        } //Close for(Core_Design_Registration_Stage__c iDRS : lstDRStages)
        
        
        List<Core_Design_Registration__c> lstDesignRegToProcess = mapGrpIdTODesignReg.values(); // After splitting the stage object record into DR and Product to split whether its for insert or update
        
        List<Core_Design_Registration__c> lstDesignRegToInsert = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> lstDesignRegToUpdate = new List<Core_Design_Registration__c>();
        
        Set<String> SetDesignRegName = new Set<String>();
        
     // Based on Stage object available records data split the DR records into insert list as well as updateDR list   
        for(Core_Design_Registration__c iDesignReg : lstDesignRegToProcess)
        {
            if(iDesignReg.Core_Registration_Number_Id__c != '')
            { 
            
                SetDesignRegName.add(iDesignReg.Core_Registration_Number_Id__c);
            
                Core_Design_Registration__c designRegUpdate = new Core_Design_Registration__c();
                designRegUpdate.put('Core_Design_Registration_Stage_Id__c', iDesignReg.get('Core_Design_Registration_Stage_Id__c'));
                
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    if(iBU.Core_Header_Or_Product_Ind__c == 'Header' && iDesignReg.get(iBU.Core_Design_API_Field_Nm__c) != '' && iDesignReg.get(iBU.Core_Design_API_Field_Nm__c) != NULL)
                    {
                        designRegUpdate.put(iBU.Core_Design_API_Field_Nm__c, iDesignReg.get(iBU.Core_Design_API_Field_Nm__c));
                    } 
                }
                lstDesignRegToUpdate.add(designRegUpdate);
            }
            else
            {
                Boolean isError = FALSE;
                
                if(iDesignReg.OwnerId != NULL )
                {
                    if(mapAllActiveUsrsEmailAndIds.containskey(iDesignReg.OwnerId))
                    {
                        iDesignReg.OwnerId = mapAllActiveUsrsEmailAndIds.get(iDesignReg.OwnerId);
                    }
                    else
                    {
                        isError = TRUE;
                        Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                        DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                        DRSObj.Core_Message_Txt__c = 'Not a valid partner user email Id';
                        
                        mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);                  
                    }
                    
                    if(!mapLoggedInUserAccountRelatedUserIds.containskey(iDesignReg.OwnerId))
                    {
                        isError = TRUE;
                        Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                        DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                        DRSObj.Core_Message_Txt__c = 'Specified Owner Email Id is not belongs to your Distributor Account';
                        
                        mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);    
                    }                
                }
                
                if(!isError)
                {
                    lstDesignRegToInsert.add(iDesignReg);
                }
            }
        } // close for
        
        Map<String, String> mapDesignRegNameTOId = new Map<String, String>();
        List<Core_Design_Registration__c> lstDesignRegNotLockedToUpdate = new List<Core_Design_Registration__c>();
        Set<Id> setDesignRegIds = new Set<Id>();
        
        for(Core_Design_Registration__c iDesignReg : [SELECT Id, Name,Core_Registration_Number_Id__c FROM Core_Design_Registration__c WHERE Name IN: SetDesignRegName]) // Is it for update?? Why this for loop????
        {
            mapDesignRegNameTOId.put(iDesignReg.Name, iDesignReg.Id);
             setDesignRegIds.add(iDesignReg.Id);
        }
     
        Map<ID, UserRecordAccess> mapDesignRegIdTOUserAccess = new Map<ID,UserRecordAccess>( [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId IN :setDesignRegIds] );
        
        for(Core_Design_Registration__c iDesignReg : lstDesignRegToUpdate) 
        {
        
            Boolean isError = FALSE;
            
            if(mapDesignRegNameTOId.containsKey(iDesignReg.Core_Registration_Number_Id__c))
            {
                iDesignReg.Id = mapDesignRegNameTOId.get(iDesignReg.Core_Registration_Number_Id__c); 
            }
            else
            {
                isError = TRUE;
                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                DRSObj.Core_Message_Txt__c = 'Not a valid registration number for update';
                
                mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);   
            }
            
            if(iDesignReg.OwnerId != NULL)
            {
                if(mapAllActiveUsrsEmailAndIds.containskey(iDesignReg.OwnerId))
                {
                    iDesignReg.OwnerId = mapAllActiveUsrsEmailAndIds.get(iDesignReg.OwnerId);
                }
                else
                {
                    isError = TRUE;
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = 'Not a valid partner user email Id';
                    
                    mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);   
                }   
                
                if(!mapLoggedInUserAccountRelatedUserIds.containskey(iDesignReg.OwnerId))
                {
                    isError = TRUE;
                
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = 'Specified Owner Email Id is not belongs to your Distributor Account';
                    
                    mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);    
                }         
            }            

            if(iDesignReg.Id != NULL)
            {
                if(mapDesignRegIdTOUserAccess.get(iDesignReg.Id).HasEditAccess != TRUE)
                {
                    isError = TRUE;
    
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = 'You do not have access to this Registration';
                    
                    mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);    
                }
    
                if(Approval.isLocked(iDesignReg.Id))
                {
                
                    isError = TRUE;
                    
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = 'The record is locked after approval and cannot be updated';
                    
                    mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);     
                }
            }
            
            if(!isError)
            {
                lstDesignRegNotLockedToUpdate.add(iDesignReg);
            }
            
        }
       
        // DML call to save the design registrations
        List<Database.SaveResult> lstDesignRegSaveResult = Database.insert(lstDesignRegToInsert, false);
        List<Database.SaveResult> lstDesignRegSaveResultUpdate = Database.update(lstDesignRegNotLockedToUpdate, false);
        
        // To handle the DR creation failure stage record ids and to update its status and error message
        for (Integer i = 0; i < lstDesignRegSaveResult.size(); i++) 
        {
            String errorMsg = 'Error While Processing/Creating DR Records \n';
            Database.SaveResult DbSaveResult = lstDesignRegSaveResult [i];
            Core_Design_Registration__c origRecord = lstDesignRegToInsert[i];
            
            if(DbSaveResult.isSuccess())
            {
                setDesignRegSuccessIds.add(DbSaveResult.getId());
            }
            else if (!DbSaveResult.isSuccess()) 
            {
                for (Database.Error err: DbSaveResult.getErrors()) 
                {
                    errorMsg +=  (err.getFields() + '\n'+ err.getMessage());
                }  
                
                mapDesignRegFailedStageRecIdsAndErrMsg.put(origRecord.Core_Design_Registration_Stage_Id__c,errorMsg);
            } // close if 
        } // close for         
      
       // During DR creation From Stage Record, If there are any run time errors then update the respecitve stage record with proper run time error message 
        if(mapDesignRegFailedStageRecIdsAndErrMsg.size() > 0)
        {
            for(Id stgRecId : mapDesignRegFailedStageRecIdsAndErrMsg.keySet())
            {
                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=stgRecId);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                DRSObj.Core_Message_Txt__c = mapDesignRegFailedStageRecIdsAndErrMsg.get(stgRecId);
                
                mapUpdateDRStg.put(stgRecId,DRSObj);
            } // Close For
        
        }// Close If
        
    
    // To handle the DR update failure stage record ids and to update its status and error message
        for (Integer i = 0; i < lstDesignRegSaveResultUpdate.size(); i++) 
        {
            String errorMsg = 'Error While Processing DR Update Records \n';
            Database.SaveResult DbSaveResult = lstDesignRegSaveResultUpdate [i];
            Core_Design_Registration__c origRecord = lstDesignRegToUpdate[i];
            
            if(DbSaveResult.isSuccess())
            {
                setDesignRegSuccessIds.add(DbSaveResult.getId());
            }
            else if (!DbSaveResult.isSuccess()) 
            {
                for (Database.Error err: DbSaveResult.getErrors()) 
                {
                    errorMsg += (err.getFields() + '\n'+ err.getMessage());
                }  
                
                mapDesignRegFailedStageRecIdsAndErrMsg.put(origRecord.Core_Design_Registration_Stage_Id__c,errorMsg);
                
            } // close if 
         
        } // close for         
      
       // During DR update From Stage Record, If there are any run time errors then update the respecitve stage record with proper run time error message 
        if(mapDesignRegFailedStageRecIdsAndErrMsg.size() > 0)
        {
            for(Id stgRecId : mapDesignRegFailedStageRecIdsAndErrMsg.keySet())
            {
                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=stgRecId);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                DRSObj.Core_Message_Txt__c = mapDesignRegFailedStageRecIdsAndErrMsg.get(stgRecId);
                System.debug('stgRecId==>'+stgRecId+' and DRSObj ==>'+DRSObj );
                
                mapUpdateDRStg.put(stgRecId,DRSObj);
            } // Close For
        
        }// Close If
             
        
              
        for(Core_Design_Registration__c  iDesignReg : lstDesignRegToInsert)
        {
            mapDesignStgIdTODesignRegId.put(iDesignReg.Core_Design_Registration_Stage_Id__c, iDesignReg.Id);
            mapDesignRegIdTODesignStgId.put(iDesignReg.Id, iDesignReg.Core_Design_Registration_Stage_Id__c); 
        }
        
        for(Core_Design_Registration__c  iDesignReg : lstDesignRegToUpdate)
        {
            mapDesignStgIdTODesignRegId.put(iDesignReg.Core_Design_Registration_Stage_Id__c, iDesignReg.Id);
            mapDesignRegIdTODesignStgId.put(iDesignReg.Id, iDesignReg.Core_Design_Registration_Stage_Id__c);
            mapDesignRegIdTODesignRegName.put(iDesignReg.Id, iDesignReg.Name);  
        }  
        
        //To identify the name of created design registration product
        for(Core_Design_Registration__c iDesignReg: [SELECT Id, Name FROM Core_Design_Registration__c WHERE Id IN: setDesignRegSuccessIds])
        {
            mapDesignRegIdTODesignRegName.put(iDesignReg.Id, iDesignReg.Name);   
        }                        
        for(Id iDesignRegID : setDesignRegSuccessIds)
        {
            {
                Core_Design_Registration_Stage__c iDRS = new Core_Design_Registration_Stage__c(Id=mapDesignRegIdTODesignStgId.get(iDesignRegID));
                iDRS.Core_Processing_Status_Nm__c = 'Successful';
                iDRS.Core_Message_Txt__c = 'Success';
                iDRS.Core_Converted_Design_Or_Product_Id__c = iDesignRegID;
                iDRS.Core_Converted_Design_Or_Product_Nm__c = mapDesignRegIdTODesignRegName.get(iDesignRegID);
                
                mapUpdateDRStg.put(iDesignRegID,iDRS);
            }
        }
      
         // Taking all the stage object available and eligible Products into list.
        for(String iGrpId : mapGrpIdTODesignRegProd.keySet())
        {
            for(Core_Design_Registration_Product__c iDesignRegProd : mapGrpIdTODesignRegProd.get(iGrpId))
            {
                Boolean isDesignRegProdErr = FALSE;  

                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                DRSObj.Core_Message_Txt__c = '';
                
                if(!mapDesignStgIdTODesignRegId.containskey(mapHeadGrpIdTODesignStgId.get(iGrpId)))
                {
                    isDesignRegProdErr = TRUE;
                    DRSObj.Core_Message_Txt__c = 'Header is not created/ found to update this child record';
                    
                }
  
                if(iDesignRegProd.Core_Product_Id__c != NULL && (!mapProductNameToProductId.containskey(iDesignRegProd.Core_Product_Id__c)))  
                {
                    isDesignRegProdErr = TRUE;
                    DRSObj.Core_Message_Txt__c += 'No Valid product found';
                }
                
                if(!isDesignRegProdErr)
                {
                    
                    iDesignRegProd.Core_Design_Registration_Id__c = mapDesignStgIdTODesignRegId.get(mapHeadGrpIdTODesignStgId.get(iGrpId));
                    
                    iDesignRegProd.Core_Product_Id__c = mapProductNameToProductId.get(iDesignRegProd.Core_Product_Id__c);
                    
                    lstProcessDesignProduct.add(iDesignRegProd);    
                }
                else
                {
                    mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj);                   
                }

            }
        } // Close For
        
        
        List<Core_Design_Registration_Product__c> lstDesignRegProdToInsert = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Product__c> lstDesignRegProdToUpdate = new List<Core_Design_Registration_Product__c>();
        
        Set<String> SetDesignRegProdName = new Set<String>();
        
        for(Core_Design_Registration_Product__c iDesignRegProd : lstProcessDesignProduct)
        {
            if(iDesignRegProd.Core_Design_Registration_Line_ID__c != '')
            {
                SetDesignRegProdName.add(iDesignRegProd.Core_Design_Registration_Line_ID__c);

                Core_Design_Registration_Product__c iDesignregProdForUpdate = new Core_Design_Registration_Product__c();

                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    iDesignregProdForUpdate.put('Core_Design_Registration_Stage_Id__c', iDesignRegProd.get('Core_Design_Registration_Stage_Id__c'));
                    if(iBU.Core_Header_Or_Product_Ind__c == 'Product' && iDesignRegProd.get(iBU.Core_Design_API_Field_Nm__c) != '' && iDesignRegProd.get(iBU.Core_Design_API_Field_Nm__c) != NULL)
                    {
                        iDesignregProdForUpdate.put(iBU.Core_Design_API_Field_Nm__c, iDesignRegProd.get(iBU.Core_Design_API_Field_Nm__c));
                    }
                }
                
                lstDesignRegProdToUpdate.add(iDesignregProdForUpdate);

            }
            else
            {
               lstDesignRegProdToInsert.add(iDesignRegProd);
            }
        
        }
        
        Map<String, String> mapDesignRegProdNameTOId = new Map<String, String>();
        List<Core_Design_Registration_Product__c> lstDesignRegProdNotApprovedToUpdate = new List<Core_Design_Registration_Product__c>();
    
        Set<Id> setDesignRegProdIds = new Set<Id>();
        
        for(Core_Design_Registration_Product__c iDesignRegProd : [SELECT Id, Name,Core_Product_Id__r.name FROM Core_Design_Registration_Product__c WHERE Name IN: SetDesignRegProdName])
        {
            mapDesignRegProdNameTOId.put(iDesignRegProd.Name, iDesignRegProd.Id);
            setDesignRegProdIds.add(iDesignRegProd.Id);
        }
        Map<ID, UserRecordAccess> mapDesignRegProdIdTOUserAccess = new Map<ID,UserRecordAccess>( [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId IN :setDesignRegProdIds] );
        for(Core_Design_Registration_Product__c iDesignRegProd : lstDesignRegProdToUpdate) 
        {
            Boolean isError = FALSE;
            if(mapDesignRegProdNameTOId.containsKey(iDesignRegProd.Core_Design_Registration_Line_ID__c))
            {
                iDesignRegProd.Id = mapDesignRegProdNameTOId.get(iDesignRegProd.Core_Design_Registration_Line_ID__c);
            }            
            else
            {
                isError = TRUE;
                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                DRSObj.Core_Message_Txt__c = 'Not a valid design registration line id for update';
                
                mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj);   
            }
            
            if(iDesignRegProd.Id != NULL)
            {
                if(mapDesignRegProdIdTOUserAccess.get(iDesignRegProd.Id).HasEditAccess != TRUE)
                {    
                    isError = TRUE;
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = 'You do not have access to this Registration';
                    
                    mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj);    
                }
                if(iDesignRegProd.Core_Design_Product_Status_Nm__c != 'Cancelled' && Approval.isLocked(iDesignRegProd.Id))
                {
                    isError = TRUE;
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = 'The record is locked after approval and cannot be updated';
                    
                    mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj);            
                }
            }
            
            
            if(!isError)
            {
                lstDesignRegProdNotApprovedToUpdate.add(iDesignRegProd);
            }
        }  

        // DML call to save the design registrations
        List<Database.SaveResult> lstDesignRegProdSaveResult = Database.insert(lstDesignRegProdToInsert, false);
        List<Database.SaveResult> lstDesignRegProdSaveResultUpdate = Database.update(lstDesignRegProdNotApprovedToUpdate, false);
        
        // To handle the DR-Product creation failure stage record ids and to update its status and error message
        for (Integer i = 0; i < lstDesignRegProdSaveResult.size(); i++) 
        {
            String errorMsg = 'Error While Processing/Creating DR-Product Records \n';
            Database.SaveResult DbSaveResult = lstDesignRegProdSaveResult [i];
            Core_Design_Registration_Product__c origRecord = lstDesignRegProdToInsert[i];
            
            if(DbSaveResult.isSuccess())
            {
                setDesignRegProdSuccessIds.add(DbSaveResult.getId());

            }
            else if (!DbSaveResult.isSuccess()) 
            {
                for (Database.Error err: DbSaveResult.getErrors()) 
                {
                    errorMsg += (err.getFields() + '\n'+ err.getMessage());
                }  
                
                mapDesignRegFailedStageRecIdsAndErrMsg.put(origRecord.Core_Design_Registration_Stage_Id__c,errorMsg);
            
            } // close if 
        
        } // close for         
      
       // During DR-Product creation From Stage Record, If there are any run time errors then update the respecitve stage record with proper run time error message 
        if(mapDesignRegFailedStageRecIdsAndErrMsg.size() > 0)
        {
            for(Id stgRecId : mapDesignRegFailedStageRecIdsAndErrMsg.keySet())
            {
                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=stgRecId);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                DRSObj.Core_Message_Txt__c = mapDesignRegFailedStageRecIdsAndErrMsg.get(stgRecId);
                
                mapUpdateDRStg.put(stgRecId,DRSObj);
            } // Close For
        
        }// Close If
        
        
        
    // To handle the DR-Product update failure stage record ids and to update its status and error message
        for (Integer i = 0; i < lstDesignRegProdSaveResultUpdate.size(); i++) 
        {
            String errorMsg = 'Error While Processing DR-Product Update Records \n';
            Database.SaveResult DbSaveResult = lstDesignRegProdSaveResultUpdate [i];
            Core_Design_Registration_Product__c origRecord = lstDesignRegProdToUpdate[i];
            
            if(DbSaveResult.isSuccess())
            {
                setDesignRegProdSuccessIds.add(DbSaveResult.getId());
            }
            else if (!DbSaveResult.isSuccess())
            {
                for (Database.Error err: DbSaveResult.getErrors()) 
                {
                    errorMsg += (err.getFields() + '\n'+ err.getMessage());
                }  
                
                mapDesignRegFailedStageRecIdsAndErrMsg.put(origRecord.Core_Design_Registration_Stage_Id__c,errorMsg);
           
            } // close if 
         
        } // close for         
      
       // During DR update From Stage Record, If there are any run time errors then update the respecitve stage record with proper run time error message 
        if(mapDesignRegFailedStageRecIdsAndErrMsg.size() > 0)
        {
            for(Id stgRecId : mapDesignRegFailedStageRecIdsAndErrMsg.keySet())
            {
                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=stgRecId);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                DRSObj.Core_Message_Txt__c = mapDesignRegFailedStageRecIdsAndErrMsg.get(stgRecId);
                System.debug('stgRecId==>'+stgRecId+' and DRSObj ==>'+DRSObj );
                
                mapUpdateDRStg.put(stgRecId,DRSObj);
            
            } // Close For
        
        }// Close If
     
        update mapUpdateDRStg.values(); 
        
        
        for(Core_Design_Registration_Product__c  iDesignRegProd : lstDesignRegProdToInsert)
        {
            mapDesignRegProdIdTODesignStgId.put(iDesignRegProd.Id, iDesignRegProd.Core_Design_Registration_Stage_Id__c);
        }
        for(Core_Design_Registration_Product__c  iDesignRegProd : lstDesignRegProdToUpdate)
        {
            mapDesignRegProdIdTODesignStgId.put(iDesignRegProd.Id, iDesignRegProd.Core_Design_Registration_Stage_Id__c);  
        } 
        
        //To identify the name of created design registration product
        for(Core_Design_Registration_Product__c  iDesignRegProd: [SELECT Id, Name FROM Core_Design_Registration_Product__c WHERE Id IN: setDesignRegProdSuccessIds])
        {
            mapDesignRegProdIdTODesignProdName.put(iDesignRegProd.Id, iDesignRegProd.Name);   
        }               
        for(Id iDesignRegProdID : setDesignRegProdSuccessIds)
        {
            {
                Core_Design_Registration_Stage__c iDRS = new Core_Design_Registration_Stage__c(Id=mapDesignRegProdIdTODesignStgId.get(iDesignRegProdID));
                iDRS.Core_Processing_Status_Nm__c = 'Successful';
                iDRS.Core_Message_Txt__c = 'Success';
                iDRS.Core_Converted_Design_Or_Product_Id__c = iDesignRegProdID;
                iDRS.Core_Converted_Design_Or_Product_Nm__c = mapDesignRegProdIdTODesignProdName.get(iDesignRegProdID);
                lstUpdateDesignRegStg.add(iDRS);
            }
        }
        
        update lstUpdateDesignRegStg;
        

    }// Close Method createDesignReg
}