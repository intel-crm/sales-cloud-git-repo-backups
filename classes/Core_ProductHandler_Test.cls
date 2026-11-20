@isTest
Public class Core_ProductHandler_Test{
    
    @isTest static void updateProductDensityTest(){
        List<Core_Product_Density_Rule__c> densityRuleList = new List<Core_Product_Density_Rule__c>();
        densityRuleList.add(addDensityRow(10,  'AGILEX F,AGILEX I,Intel® Agilex™ F,Intel® Agilex™ I', 'NA', 'NA',  'NA',                                                                           '4',  '7',     '',   TRUE));
        densityRuleList.add(addDensityRow(20,  'Intel® eASIC™', 'NA', 'NA',  'NA',                                                                           '0',  '_',     '',   TRUE));
        densityRuleList.add(addDensityRow(30,  'ARRIA 10 GX,ARRIA 10 SX,Intel® Arria® 10 GX,Intel® Arria® 10 SX', '4',  '7',   '016,022,027,032,048,057,066,090',                                       '5',  '7',     '0',  TRUE));
        densityRuleList.add(addDensityRow(40,  'ARRIA 10 GX,ARRIA 10 SX,Intel® Arria® 10 GX,Intel® Arria® 10 SX', '4',  '7',   '115',                                                                          '4',  '7',     '0',  TRUE));
        densityRuleList.add(addDensityRow(50,  'ARRIA II GX', '0',  '9',   'EP2AGX190,EP2AGX260,EP2AGX125',                                              '0',  '9',     '',   TRUE));
        densityRuleList.add(addDensityRow(60,  'ARRIA II GX', '0',  '8',   'EP2AGX20,EP2AGX30,EP2AGX45,EP2AGX65,EP2AGX95',                             '0',  '8',     '',   TRUE));
        densityRuleList.add(addDensityRow(70,  'ARRIA II GZ', '0',  '9',   'EP2AGZ225,EP2AGZ300,EP2AGZ350',                                              '0',  '9',     '',   TRUE));
        densityRuleList.add(addDensityRow(80,  'ARRIA V GT,ARRIA V GX,ARRIA V GZ,ARRIA V ST,ARRIA V SX', '0',  '4',   'NA',                                                                           '0,4','5,7',   '',   TRUE));
        densityRuleList.add(addDensityRow(90,  'CYCLONE 10 GX,CYCLONE 10 LP,Intel® Cyclone® 10 GX,Intel® Cyclone® 10 LP', 'NA', 'NA',  'NA',                                                                           '0',  '7',     '',   TRUE));
        densityRuleList.add(addDensityRow(100, 'CYCLONE V GX,CYCLONE V SE,Cyclone® V GT,Cyclone® V GX,Cyclone® V SE,Cyclone® V ST,Cyclone® V SX', 'NA', 'NA',  'NA',                                                                           '0,4','6,7',   '',   TRUE));
        densityRuleList.add(addDensityRow(110, 'CYCLONE V E', 'NA', 'NA',  'NA',                                                                           '0,3','5,6',   '',   TRUE));
        densityRuleList.add(addDensityRow(120, 'CYCLONE IV E', '0',  '6',   'EP4CE6',                                                                       '0',  '6',     '',   TRUE));
        densityRuleList.add(addDensityRow(130, 'CYCLONE IV E', '0',  '7',   'EP4CE10,EP4CE15,EP4CE22,EP4CE30,EP4CE40,EP4CE55,EP4CE75',                '0',  '7',     '',   TRUE));
        densityRuleList.add(addDensityRow(140, 'CYCLONE IV E', '0',  '8',   'EP4CE115',                                                                     '0',  '8',     '',   TRUE));
        densityRuleList.add(addDensityRow(150, 'MAX 10,Intel® MAX® 10', 'NA', 'NA',  'NA',                                                                           '0',  '5',     '',   TRUE));
        densityRuleList.add(addDensityRow(160, 'Intel® Stratix® 10 DX,STRATIX 10 DX', '3',  '6',   '110,210,280',                                                                '3',  '6',     '0',  TRUE));
        densityRuleList.add(addDensityRow(170, 'Intel® Stratix® 10 DX,STRATIX 10 DX', '3',  '5',   '21',                                                                           'NA', 'NA',    '0',  TRUE));
        densityRuleList.add(addDensityRow(180, 'Intel® Stratix® 10 GX,Intel® Stratix® 10 SX,Intel® Stratix® 10 TX,STRATIX 10 GX,STRATIX 10 SX,STRATIX 10 TX', '3',  '6',   '040,065,085',                                                                '4',  '6',     '0',  TRUE));
        densityRuleList.add(addDensityRow(190, 'Intel® Stratix® 10 GX,Intel® Stratix® 10 SX,Intel® Stratix® 10 TX,STRATIX 10 GX,STRATIX 10 SX,STRATIX 10 TX', '3',  '6',   '110,160,165,166,200,210,211,250,280',                                  '3',  '6',     '0',  TRUE));
        densityRuleList.add(addDensityRow(200, 'Intel® Stratix® 10 GX,Intel® Stratix® 10 SX,Intel® Stratix® 10 TX,STRATIX 10 GX,STRATIX 10 SX,STRATIX 10 TX', '3',  '6',   '10M',                                                                          '3',  '6',     '',   TRUE));
        densityRuleList.add(addDensityRow(210, 'Intel® Stratix® 10 MX,STRATIX 10 MX', '3',  '6',   '165,210',                                                                     '3',  '6',     '0',  TRUE));
        densityRuleList.add(addDensityRow(220, 'Intel® Stratix® 10 MX,STRATIX 10 MX', '3',  '5',   '16',                                                                           '3',  '5',     '50', TRUE));
        densityRuleList.add(addDensityRow(230, 'Intel® Stratix® 10 MX,STRATIX 10 MX', '3',  '5',   '11, 21',                                                                       '3',  '5',     '0',  TRUE));
        densityRuleList.add(addDensityRow(240, 'Intel® Stratix® 10 NX', '3',  '5',   '21',                                                                           '3',  '5',     '0',  TRUE));
        densityRuleList.add(addDensityRow(250, 'Intel® Stratix® 10 AX', '3',  '5',   '28',                                                                           '3',  '5',     '0',  TRUE));
        densityRuleList.add(addDensityRow(260, 'STRATIX III,Stratix® III', '0',  '7',   'EP3SE50,EP3SE80,EP3SL50,EP3SL70',                                           '0',  '7',     '',   TRUE));
        densityRuleList.add(addDensityRow(270, 'STRATIX III,Stratix® III', '0',  '7',   'EP3SE110,EP3SE260,EP3SL110,EP3SL150,EP3SL200,EP3SL340',                  '0',  '8',     '',   TRUE));
        densityRuleList.add(addDensityRow(280, 'STRATIX IV E,Stratix® IV E', '0',  '8',   'EP4SE110,EP4SE230,EP4SE290,EP4SE360,EP4SE530,EP4SE680,EP4SE820',         '0',  '8',     '',   TRUE));
        densityRuleList.add(addDensityRow(290, 'STRATIX IV GT,Stratix® IV GT', '0',  '8',   'EP4S40G2,EP4S40G5',                                                           '0',  '8',     '',   TRUE));
        densityRuleList.add(addDensityRow(300, 'STRATIX IV GT,Stratix® IV GT', '0',  '9',   'EP4S100G2,EP4S100G3,EP4S100G4,EP4S100G5',                                   '0',  '9',     '',   TRUE));
        densityRuleList.add(addDensityRow(310, 'STRATIX IV GX,Stratix® IV GX', '0',  '8',   'EP4SGX70',                                                                     '0',  '8',     '',   TRUE));
        densityRuleList.add(addDensityRow(320, 'STRATIX IV GX,Stratix® IV GX', '0',  '9',   'EP4SGX110,EP4SGX180,EP4SGX230,EP4SGX290,EP4SGX360,EP4SGX530',             '0',  '9',     '',   TRUE));
        densityRuleList.add(addDensityRow(330, 'STRATIX V E,Stratix® V E', '0',  '5',   '5SEE9,5SEEB',                                                                 '0',  '5',     '',   TRUE));
        densityRuleList.add(addDensityRow(340, 'STRATIX V GS,STRATIX V GX,Stratix® V GS,Stratix® V GX', 'NA', 'NA',  'NA',                                                                           '0,4','6,7',   '',   TRUE));
        densityRuleList.add(addDensityRow(350, 'STRATIX V EG', '0,4',  '4,5',   '5SEE9,5SEEB',                                                                 '0,4',  '4,5',      '',   TRUE));
        densityRuleList.add(addDensityRow(360, 'STRATIX V EK', '0,4',  '4,5',   '5SEE9,5SEEB','0',  '5',      '0',   TRUE));
        densityRuleList.add(addDensityRow(370, 'STRATIX V EK1', '0,4',  '4,5',   '5SEE9,5SEEB','0',  'E',      '0',   TRUE));
        densityRuleList.add(addDensityRow(380,  'ARRIA 10 GXK', '4',  '7',   '016,022,027,032,048,057,066,090','5,6',  '6,7',     '0',  TRUE));
        //densityRuleList.add(addDensityRow(390,  'ARRIA 10 GXK1', '4',  '7',   '016,022,027,032,048,057,06B,090,06B','5,6',  'B',     '0',  TRUE));
        insert densityRuleList;
        /*system.debug(densityRuleList.size());
        for(Core_Product_Density_Rule__c density : [Select Id, Core_Sequence_Number__c, Core_Code_Name__c, Core_OPN_Start_Char__c, Core_OPN_End_Char__c, Core_OPN_Char_Contain__c, 
                                                    Core_Density_Start_Char__c, Core_Density_End_Char__c, Core_Density_Output_Suffix__c,Core_IsActive__c 
                                                    from Core_Product_Density_Rule__c where Core_IsActive__c  = True and Id IN :densityRuleList Order by Core_Sequence_Number__c asc ]){
                                                        
                                                        System.debug(density);
                                                    }*/
        
        List<Product2> newProdList = new List<Product2>();        
        newProdList.add(addProductDetails(True, '59', 'Intel® eASIC™', 'N3XSTe15_FC900','Intel® eASIC™ N3XSTe15_FC900'));
        newProdList.add(addProductDetails(True, '59', 'AGILEX I', 'AGIA014R29C2E3VR0','AGILEX I AGIA014R29C2E3VR0'));
        newProdList.add(addProductDetails(True, '59', 'CYCLONE IV E', 'EP4CE40F19C8N','CYCLONE IV E EP4CE40F19C8N'));
        newProdList.add(addProductDetails(True, '59', 'STRATIX V GS', '5SGSED8K3F40C2G','STRATIX V GS 5SGSED8K3F40C2G'));
        newProdList.add(addProductDetails(True, '59', 'STRATIX V GS', '5SGSMD6K3F40C3G','STRATIX V GS 5SGSMD6K3F40C3G'));
        newProdList.add(addProductDetails(True, '59', 'ARRIA 10 GX', '10AX066N3F40I2SGAA','ARRIA 10 GX 10AX066N3F40I2SGAA'));
        newProdList.add(addProductDetails(True, '59', 'STRATIX V EG', '5SEE95SEE95SEE95SEE9','STRATIX V GS 5SGSED8K3F40C2GFG'));
        newProdList.add(addProductDetails(True, '59', 'STRATIX V EK', '5SEE95SEE95SEE95SEE9','STRATIX V GS 5SGSED8K3F40C2GFK'));
        newProdList.add(addProductDetails(True, '59', 'STRATIX V EK1', '5SEE95SEE95SEE95SEE9','STRATIX V GS 5SGSED8K3F40C2GFK1'));
        newProdList.add(addProductDetails(True, '59', 'ARRIA 10 GXK', '10AX066N3F40I2SGAA','ARRIA 10 GXK 10AX066N3F40I2SGAA'));

        	

        insert newProdList;
		

        
    }
    
    
    private static Core_Product_Density_Rule__c addDensityRow(Integer codeSeqNumber, String codeName, string OPNStartChar, string OPNEndChar, String OPNCharContain, String densityStartChar, String densityEndChar, String densityOutputSuffix, Boolean isActive ){
        Core_Product_Density_Rule__c densityRule = new Core_Product_Density_Rule__c();
        densityRule.Core_Sequence_Number__c = codeSeqNumber;
        densityRule.Core_Code_Name__c = codeName;
        densityRule.Core_OPN_Start_Char__c = OPNStartChar;
        densityRule.Core_OPN_End_Char__c = OPNEndChar;
        densityRule.Core_OPN_Char_Contain__c = OPNCharContain;
        densityRule.Core_Density_Start_Char__c = densityStartChar;
        densityRule.Core_Density_End_Char__c = densityEndChar;
        densityRule.Core_Density_Output_Suffix__c = densityOutputSuffix;
        densityRule.Core_IsActive__c  = isActive;
        
        return densityRule;
        
    }
    
    private static Product2 addProductDetails( boolean isActive, String hierarchyId, string codeName, string OPN, String Name ){
         Product2 newProd = new Product2();
        newProd.Name = Name;
        newProd.IsActive = isActive;
        newProd.Core_Hierarchy_ID__c= hierarchyId;
        newProd.Core_Code_Name__c = codeName;
        newProd.Core_OPN__c=OPN;
        return newProd;
    }
    
    
    
    @isTest static void updateSalesVisibleFlagForPSGTest(){
     	Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Integration' LIMIT 1];
       	User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON123',
                           Alias = 'jliv',
                           Email = 'jason88.liveston@example.com',
                           Username = 'jason12388.liveston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
      System.runAs(usr) {
              // The following code runs as user 'u'
              System.debug('Current User: ' + UserInfo.getUserName());
              System.debug('Current Profile: ' + UserInfo.getProfileId());
               Product2 productRec = new Product2();
        productRec.Name = 'Test';
        productRec.Core_Sales_Visible_Flag__c = true;
        productRec.Core_Sales_Visible_Flag_User_Edit__c = true;
        productRec.Core_OPN__c = '10AX066N3F40I2SGAA';        
        insert productRec;
        
        Product2 productRec2 = new Product2();
        productRec2.Core_OPN__c = '10AX066N3F40I2SGAA';
        productRec2.Id = productRec.Id;
        update productRec2;
        
           system.debug('Product Record'+productRec);
      }
    }
    
    @isTest static void updateSalesVisibleDesignRegistrationFlags(){
        Product2 newProd = new Product2();
        newProd.Name = 'STRATIX 10 GX 1SG280LN2F43E2LGS3';
        newProd.IsActive = True;
        newProd.Core_Item_Class_Nm__c = 'BD';
        newProd.Core_Product_Status__c = 'OB';
        
        insert newProd;
    }
    
    @isTest static void checkProductStatusTest(){
        Product2 newProd = new Product2();
        newProd.Name = 'STRATIX 10 GX 1SG280LN2F43E2LGS3';
        newProd.IsActive = True;
        newProd.Core_Item_Class_Nm__c = 'SV';
        newProd.Core_Product_Type__c = 'Intel® FPGAs';
        newProd.Core_Product_Org__c = 'Sales';
        newProd.Core_Product_Status__c = 'RT';
        
        insert newProd;
    }
    

}