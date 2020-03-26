/*********************************************************************
Class Name: SearchROAETemplates_AC
Created By: MST - Robert Jaramillo 
Created On: 03-12-2020
Description: Controller for SearchROAETemplates lightning component.
*********************************************************************/
public without sharing class SearchROAETemplates_AC {
    
    @AuraEnabled
    public static List<RO_OAE_Template__c> getAllTemplates(String inputSearchText) {
        if(inputSearchText == null || inputSearchText == '') {
            return [SELECT Id, Name, ROAE_Description__c FROM RO_OAE_Template__c ORDER BY Name ASC];
        }else {
            String composedFilter = sanitizeQueryString(inputSearchText);
        	return [SELECT Id, Name, ROAE_Description__c FROM RO_OAE_Template__c WHERE Name LIKE :composedFilter ORDER BY Name ASC];
        }
    }
    
    private static String sanitizeQueryString(String aQuery) {
               
        String trimmedQuery = aQuery.trim();
        if (trimmedQuery.length() == 0) return '%';
        return '%' + trimmedQuery.replaceAll('\\W+', '%') + '%';
    }
}