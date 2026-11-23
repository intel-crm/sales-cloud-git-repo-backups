/**
* @File Name : Core_AccountPlan_PDFController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : April 30, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 30, 2025 |   | Initial Version
**/

public class Core_AccountPlan_PDFController {
    
    public AccountPlan record { get; set; }
    public List<CRM_Hot_Button__c> hotButtonRecords { get; set; }
    public List<AccountPlanObjective> accountPlanObjRecords { get; set; }
    public List<CRM_Intel_Account_Plan_Rev__c> intelAccountPlanRevRecords { get; set; }
    public String CRM_Intel_Values { get; set; }
    public String CRM_Year { get; set; }
    public String CRM_BU { get; set; }
    public String CRM_Account_Potential_Revenue { get; set; }
    public String CRM_Partners { get; set; }
    public String CRM_Competition { get; set; }
    public List<Opportunity> oppRecords { get; set; }
    public String TransformationalComments { get; set; }
    public String Relationship_Map_Comments { get; set; }
    public Id contentVersionId { get; set; }
    public Account relatedAccount { get; set; }
    public String accountUrl { get; set; }
    public String CRM_AccountVision { get; set; }
    
    public Core_AccountPlan_PDFController() {
        
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        String recordName = ApexPages.currentPage().getParameters().get('Name');
        contentVersionId = ApexPages.currentPage().getParameters().get('cid');       
        String baseUrl = ApexPages.currentPage().getHeaders().get('Host');

        
        record = [
            
            SELECT Id, Name,AccountId,StartDate,EndDate,AccountVision,Status,Core_Account_Plan_Score_Nm__c,Core_Market_Cap__c,Core_Account_Revenue__c,Core_Net_Income__c,Core_Cash_Investments__c,Core_Debt_long_term__c,Core_Price_Earnings__c,Core_Gross_Margin__c,Core_Employees__c,
            CRM_Financial_Year__c,Core_Account_Revenue_Comments__c,Core_Customer_Objectives__c,CRM_Intel_Values__c,Transformational_Opportunities__c,Transformational_Opportunities_Comment_N__c,
            CRM_Relationship_Map_Comments__c,CRM_Customer_Nm__c,CRM_Account_Value_Impact_to_Intel__c,CRM_Intel_Partner_Alliance_Activity__c,CRM_Recent_Customer_Announcements__c,CRM_Partners__c,CRM_Competition__c
            FROM AccountPlan
            
            WHERE Id = :recordId
            
            LIMIT 1
            
        ];	

        relatedAccount = [SELECT Id, Name FROM Account WHERE Id = :record.AccountId LIMIT 1];
        accountUrl = 'https://' + baseUrl + '/' + relatedAccount.Id;
        
        hotButtonRecords = [
            
            SELECT Id,CRM_Description__c,CRM_Account_Plan__c
            FROM CRM_Hot_Button__c
            WHERE CRM_Account_Plan__c =:recordId           
            
        ];
        
        accountPlanObjRecords = [
            SELECT Id,Name,Status,ObjectiveOwner.Name,StartDate,Core_Objective_Comments_Section__c,EndDate,Description,
            (SELECT ID,ValueType,TargetValue,CurrentValue FROM AccountPlanObjectiveMeasures)
            FROM AccountPlanObjective
            WHERE AccountPlanId =:recordId order by createdDate          
        ];
        
        intelAccountPlanRevRecords = [
            SELECT Id,CRM_Year__c,CRM_BU__c,CRM_Account_Potential_Revenue__c,CRM_Account_Plan__c
            FROM CRM_Intel_Account_Plan_Rev__c
            WHERE CRM_Account_Plan__c =:recordId
        ];
        
        CRM_Intel_Values = adjustImageSize(record.CRM_Intel_Values__c);
        CRM_Partners = adjustImageSize(record.CRM_Partners__c);
        CRM_Competition = adjustImageSize(record.CRM_Competition__c);
        CRM_AccountVision = adjustImageSize(record.AccountVision);
        
        
        /*---Transformation opportunity--*/
        if (record.Transformational_Opportunities__c != null) {
            // Split the ID string
            List<String> idList = record.Transformational_Opportunities__c.split(',');
            
            // Clean IDs (remove whitespace)
            List<Id> cleanIdList = new List<Id>();
            for (String rawId : idList) {
                if (String.isNotBlank(rawId)) {
                    cleanIdList.add(rawId.trim());
                }
            }
            
            oppRecords = [SELECT Id, Name, Amount, CloseDate,StageName FROM Opportunity WHERE Id IN :cleanIdList];
        } else {
            oppRecords = new List<Opportunity>();
        }
        //Transformational comments
        TransformationalComments = adjustImageSize(record.Transformational_Opportunities_Comment_N__c);
        
        //Relationship Map Comments 
        Relationship_Map_Comments = adjustImageSize(record.CRM_Relationship_Map_Comments__c);
        
    }
    
    
    private String adjustImageSize(String content) {
        if (String.isNotBlank(content)) {
            // Inject style into <img> tags
            content = content.replaceAll('<img', '<img style="width:80%;max-width:300px;height:auto"');
        }
        return content;
    }  
    
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getYearlyCategoryData() {
        
        List<AggregateResult> results = [
            SELECT CRM_Year__c year, CRM_BU__c category, SUM(CRM_Account_Potential_Revenue__c) total 
            FROM CRM_Intel_Account_Plan_Rev__c
            WHERE CRM_Year__c != null AND CRM_BU__c != null 
            GROUP BY CRM_Year__c, CRM_BU__c
            ORDER BY CRM_Year__c
        ];
        
        Set<String> years = new Set<String>();
        Set<String> categories = new Set<String>();
        Map<String, Map<String, Decimal>> dataMap = new Map<String, Map<String, Decimal>>();
        
        for (AggregateResult ar : results) {
            String year = String.valueOf(ar.get('year'));
            String category = (String) ar.get('category');
            Decimal amount = (Decimal) ar.get('total');
            
            years.add(year);
            categories.add(category);
            
            if (!dataMap.containsKey(category)) {
                dataMap.put(category, new Map<String, Decimal>());
            }
            dataMap.get(category).put(year, amount);
        }
        
        return new Map<String, Object>{
            'years' => new List<String>(years),
                'categories' => new List<String>(categories),
                'dataMap' => dataMap
                };
                    }
    
    @AuraEnabled
    public static String uploadChartImage(String base64Image) {
        if (String.isBlank(base64Image)) {
            throw new AuraHandledException('Image data is empty.');
        }
        System.debug('base64Image_c--'+base64Image);
        // Decode the base64 string
        Blob imageBlob = EncodingUtil.base64Decode(base64Image);
        
        // Create ContentVersion record
        ContentVersion cv = new ContentVersion();
        cv.Title = 'ChartImage_' + DateTime.now().getTime();
        cv.PathOnClient = 'chart.png';
        cv.VersionData = imageBlob;
        System.debug('cv_c--'+cv);
        
        insert cv;
        
        return cv.Id;
    }
    
    @AuraEnabled
    public static String getPdfBase64(Id recordId, Id contentVersionId) {
        if (String.isBlank(contentVersionId)) {
            throw new AuraHandledException('Invalid contentVersionId.');
        }
        
        // Generate the page as PDF
        PageReference pdfPage = Page.CRM_AccountPlanPDFpage;
        pdfPage.getParameters().put('id', recordId);
        pdfPage.getParameters().put('cid', contentVersionId);
        
        Blob pdfBlob = pdfPage.getContentAsPDF();
        return EncodingUtil.base64Encode(pdfBlob);
    } 
    
}