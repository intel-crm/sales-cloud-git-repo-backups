public without sharing class Core_ACM_AddressBuilder {

    public static List<Core_ACM_PayloadWrapper.PersonPhysicalAddress> buildPhysicalAddress(Contact contact) {
        List<Core_ACM_PayloadWrapper.PersonPhysicalAddress> personPhysicalAddresses = new List<Core_ACM_PayloadWrapper.PersonPhysicalAddress>();
        Core_ACM_PayloadWrapper.PersonPhysicalAddress personPhysicalAddress = new Core_ACM_PayloadWrapper.PersonPhysicalAddress();
        personPhysicalAddress.CountryCode = ((String.isNotBlank(contact.MailingCountryCode)) && (contact.MailingCountryCode != null))
            ? Core_ACM_PayloadBuilder.getISO2CountryCode(contact.MailingCountryCode)
            : Core_ACM_PayloadBuilder.getISO2CountryCode(contact.Account.BillingCountryCode);
        if (contact.MailingStateCode != null) {
            personPhysicalAddress.State = contact.MailingStateCode;
        }
        personPhysicalAddresses.add(personPhysicalAddress);
        return personPhysicalAddresses;
    }

    public static List<Core_ACM_PayloadWrapper.PersonElectronicAddress> buildElectronicAddress(Contact contact, Map<Id, Contact> oldContactMap) {
        List<Core_ACM_PayloadWrapper.PersonElectronicAddress> personElectronicAddresses = new List<Core_ACM_PayloadWrapper.PersonElectronicAddress>();
        if (contact.Phone != null) {
            personElectronicAddresses.add(new Core_ACM_PayloadWrapper.PersonElectronicAddress(Core_ACM_Constants.ADDRESS_TYPE_PHONE, contact.Phone));
        } else if (String.isBlank(contact.Phone) && oldContactMap != null && !oldContactMap.isEmpty()
                   && oldContactMap.containsKey(contact.Id) && !String.isBlank(oldContactMap.get(contact.Id).Phone)) {
            personElectronicAddresses.add(new Core_ACM_PayloadWrapper.PersonElectronicAddress(Core_ACM_Constants.ADDRESS_TYPE_PHONE, ''));
        }
        if (contact.MobilePhone != null) {
            personElectronicAddresses.add(new Core_ACM_PayloadWrapper.PersonElectronicAddress(Core_ACM_Constants.ADDRESS_TYPE_MOBILE, contact.MobilePhone));
        } else if (String.isBlank(contact.MobilePhone) && oldContactMap != null && !oldContactMap.isEmpty()
                   && oldContactMap.containsKey(contact.Id) && !String.isBlank(oldContactMap.get(contact.Id).MobilePhone)) {
            personElectronicAddresses.add(new Core_ACM_PayloadWrapper.PersonElectronicAddress(Core_ACM_Constants.ADDRESS_TYPE_MOBILE, ''));
        }
        return personElectronicAddresses;
    }
}