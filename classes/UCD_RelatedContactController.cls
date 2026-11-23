public with sharing class UCD_RelatedContactController {
    @AuraEnabled(cacheable=true)
    public static list<Contact> getRelatedList(Id recordId)
    {
        List<Contact> Conlist = [Select id, name from Contact where AccountId=: recordId ];
        return Conlist;
    }
}