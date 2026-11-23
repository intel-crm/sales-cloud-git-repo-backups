public Class PRM_ACMUpdateUtilityWrapper{
    public static  Set<id> contactIdSet = new Set<id>();
    public static    Map<Id,String> accountIdRecTypemap = new Map<Id,String>(); // keep the accounts with record type to assign benefits
    public static    Map<Id, Set<Id>> actIdCtIdMap = new Map<Id, Set<Id>>();
    public static    Map<Id, String> contactIdRelName = new Map<id, String>();
    public static    Map<Id, Id> ctIdActIdMp = new Map<Id, Id>();
    public static    Map<Id, String> actIdRoleTierMap = new Map<Id, String>(); // keep account id and new partner role tier
    public static    map<Id,String> tierIdNames = new Map<Id,String>();
    public static    Map<Id,List<String>> oldPartnerRoleMap = new Map<Id, List<String>>();
    public static    Map<Id,List<String>> newPartnerRoleMap = new Map<Id, List<String>>();
    public static    String logEntry='';
    public static    List<PRM_AccountChannelMembership__c> acmsTobeUpdated = new List<PRM_AccountChannelMembership__c>();
    public static    Map<Id, String> oldAcmIdPartnerRole = new  Map<Id, String>();
    public static    Map<Id,Id> acmIdActId = new Map<Id,Id>();
    public static    Map<Id, List<PRM_AccountChannelMembership__c>> actACMListMap = new Map<id,List<PRM_AccountChannelMembership__c>>();
    public static    Map<id, List<PRM_AccountChannelMembership__c>> opidACMListMap  = new Map<id, List<PRM_AccountChannelMembership__c>>();
    public static    Map<String, String> actIdCPLMap = new Map<String, String>();
    public static    Map<String,String> partnerRoleTierMap = new Map<String,String>();
    public static    Map<Id,List<PRM_AccountChannelMembership__c>> opidChildACMMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
    public static    Map<id,PRM_IPA_Membership__c> acmMemmap = new Map<id,PRM_IPA_Membership__c>();
    public static    Map<id,String> accountTierMap = new Map<id,String>();
    public static    Map<id,String> accountOldRoleMap = new Map<id,String>();
    public static    map<String,Id> tierNameIds = new Map<String,Id>();
    public static    Map<id, Id> opidCPLMap  = new Map<Id,Id>();
    public static    List<PRM_IPA_Membership__c> membershipList  = new List<PRM_IPA_Membership__c>(); // can be need anywhere
    public static    List<Id> actSpecificABAList = new List<Id>();
    public static    List<PRM_AccountChannelMembership__c> actSpecifiAcmList = new List<PRM_AccountChannelMembership__c>();
    public static    List<PRM_AccountBenefitAssociation__c> finalABAList = new List<PRM_AccountBenefitAssociation__c>();
    public static    List<PRM_AccountChannelMembership__c> childAcmList = new List<PRM_AccountChannelMembership__c>();
    public static   Map<String, Integer> tierRank = new Map<String, Integer>{'Member'=>1,'Gold'=>2,'Titanium'=>3};
        public static List<PRM_IPA_Membership__c> pendingChangeRequests = new List<PRM_IPA_Membership__c>();
}